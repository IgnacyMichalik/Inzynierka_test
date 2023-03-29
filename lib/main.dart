import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'uq3mIDo6JrLvcUXVIr8PUU56gTXbMFtqM2kuPPga';
  final keyClientKey = 'jcYVbSnDf2phLSJJV4RYMb3LgU2t84KUb6vOV0Ge';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    title: 'Flutter - Storage File',
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> items = [
    "Drogowe",
    "Pogoda",
    "Niebezpieczny obiekt",
    "Zagospodarowanie terenu",
    "Inne"
  ];
  String? selectedItem = "Drogowe";
  PickedFile? pickedFile;

  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 300,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                  child: Text('Dodaj zdjęcie'),
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SavePage()),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                  child: SizedBox(
                      width: 240,

                      child: DropdownButton<String>(
                        alignment: Alignment.center,
                        value: selectedItem,
                        items: items
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item,textAlign:TextAlign.center, style: TextStyle(fontSize: 24,)),
                        ))
                            .toList(),
                        onChanged: (item) => setState(() => selectedItem = item),
                      ))),
              SizedBox(
                height: 16,
              ),
              Container(
                child: (
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Dodaj opis zgłoszenia"
                      ),
                    )
                ),

              )
            ],
          ),
        ));
  }
}

class SavePage extends StatefulWidget {
  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  PickedFile? pickedFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodawanie zdjęcia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            GestureDetector(
              child: pickedFile != null
                  ? Container(
                  width: 250,
                  height: 250,
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.blue)),
                  child: kIsWeb
                      ? Image.network(pickedFile!.path)
                      : Image.file(File(pickedFile!.path)))
                  : Container(
                width: 250,
                height: 250,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.blue)),
                child: Center(
                  child: Text('Kliknij by wybrać'),
                ),
              ),
              onTap: () async {
                PickedFile? image =
                await ImagePicker().getImage(source: ImageSource.gallery);

                if (image != null) {
                  setState(() {
                    pickedFile = image;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Container(
                height: 50,
                child: ElevatedButton(
                  child: Text('Dodaj zdjęcie'),
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  onPressed: isLoading || pickedFile == null
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });
                    ParseFileBase? parseFile;

                    if (kIsWeb) {
                      //Flutter Web
                      parseFile = ParseWebFile(
                          await pickedFile!.readAsBytes(),
                          name: 'image.jpg'); //Name for file is required
                    } else {
                      //Flutter Mobile/Desktop
                      parseFile = ParseFile(File(pickedFile!.path));
                    }
                    await parseFile.save();

                    final gallery = ParseObject('Gallery')
                      ..set('file', parseFile);
                    await gallery.save();

                    setState(() {
                      isLoading = false;
                      pickedFile = null;
                    });

                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                          'Pomyślnie dodano zdjęcie',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blue,
                      ));
                  },
                ))
          ],
        ),
      ),
    );
  }
}

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Display Gallery"),
      ),
      body: FutureBuilder<List<ParseObject>>(
          future: getGalleryList(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error! Zdjęcie nie zostało dodane!"),
                  );
                } else {
                  return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        //Web/Mobile/Desktop
                        ParseFileBase? varFile =
                        snapshot.data![index].get<ParseFileBase>('file');

                        //Only iOS/Android/Desktop
                        /*
                        ParseFile? varFile =
                            snapshot.data![index].get<ParseFile>('file');
                        */
                        return Image.network(
                          varFile!.url!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.fitHeight,
                        );
                      });
                }
            }
          }),
    );
  }

  Future<List<ParseObject>> getGalleryList() async {
    QueryBuilder<ParseObject> queryPublisher =
    QueryBuilder<ParseObject>(ParseObject('Gallery'))
      ..orderByAscending('createdAt');
    final ParseResponse apiResponse = await queryPublisher.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
