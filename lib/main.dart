
import 'dart:async';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'MapScreen.dart';


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

//
// baza danych!!!!!!!!!!!!!!!!
//
class _HomePageState extends State<HomePage> {
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
                height: 20,
              ),

              Container(
                height: 200,
                child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/c/c8/POL_S%C5%82upsk_herb_S%C5%82upska.jpg'),
              ),
              SizedBox(
                height: 16,
              ),
              Center(

              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                  child: Text('Dodaj zgłoszenie'),
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
                height: 8,
              ),
              Container(
                  height: 50,
                  child: ElevatedButton(
                    child: Text('Przesłane zgłoszenia'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DisplayPage()),
                      );





                    },
                  ))
            ],
          ),
        ));
  }
}


//Mapa






class SavePage extends StatefulWidget {
  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {


  final Opis = TextEditingController();
  final Kategoria = TextEditingController();

  void doUserLogin() async {
    final Descriptrion = Opis.text.trim();
    final Category = Kategoria.text.trim();

    final Dane = ParseObject("Zgloszenie")
      ..set("Opis", Descriptrion)..set("Kategoria", Category);
    await Dane.save();

  }

  //Zdjęcia!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



  PickedFile? pickedFile;

  var zmienna = 0;

  Future state() async {
    zmienna = zmienna + 1;
  }


//Lista

bool isLoading = false;


  List<String> items = [
    "Drogowe",
    "Pogoda",
    "Niebezpieczny obiekt",
    "Zagospodarowanie terenu",
    "Inne"
  ];
  String? selectedItem = "Inne";


  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text("Przesłane zgłoszenia"),
        ),


        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              SizedBox(
                height: 16,
              ),

              //Mapa
             ElevatedButton(
              child: Text('Wybierz lokalizacje'),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
                },
            ),


              SizedBox(
                height: 16,
              ),
              //Zdjęcia


              SizedBox(
                height: 16,
              ),
              Column(
                children: [
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
                      width: 150,
                      height: 150,
                      decoration:
                      BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: Center(
                        child: Text('Dodaj zdjęcie'),
                      ),
                    ),
                    onTap: () async {


                      /*  await  showDialog(context: context, builder: (context)=> AlertDialog(
                            title: Text("Dodawanie zdjęcia"),
                            actions: [
                              ElevatedButton(onPressed:() async{pickImageC();
                                Navigator.pop(context);},
                                  child: Text('    Zrób zdjęice     ')),
                              ElevatedButton(onPressed: () async{pickImage();Navigator.pop(context);

                                }, child: Text('Zdjęcie z galerii'))
                            ],

                          ));
*/

                      await showDialog(context: context, builder: (context) =>
                          AlertDialog(
                            title: Text("Dodawanie zdjęcia"),
                            actions: [
                              ElevatedButton(onPressed: () async {
                                state();
                                Navigator.pop(context);
                              }, child: Text('Zrób zdjęcie')),

                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context)
                                  , child: Text('Zdjęcie z galerii'))
                            ],

                          ));

                      if (zmienna == 1) {
                        PickedFile? image =
                        await ImagePicker().getImage(
                            source: ImageSource.camera);
                        zmienna = zmienna - 1;
                        if (image != null) {
                          setState(() {
                            pickedFile = image;
                          });
                        }
                      } else if (zmienna == 0) {
                        PickedFile? image =
                        await ImagePicker().getImage(
                            source: ImageSource.gallery);

                        if (image != null) {
                          setState(() {
                            pickedFile = image;
                          });
                        }
                      }
                    },

                  )
                ],

              ),


              SizedBox(
                height: 16,
              ),


              Container(
                  child: SizedBox(
                      width: 240,
                      height: 50,


                      child: Center(child:
                      DropdownButtonFormField(

                        value: selectedItem,
                        items: items
                            .map((item) =>
                            DropdownMenuItem<String>(
                                value: item,
                                child: Center(child:
                                Text(item, textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20,)),
                                )))
                            .toList(),
                        onChanged: (String? newValue) {
                          Kategoria.text = newValue!;
                              (item) => setState(() => selectedItem = item);
                        },
                      )))),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                child: (
                    TextFormField(

                      textAlign: TextAlign.center,
                      controller: Opis,
                      decoration: InputDecoration(
                          hintText: "Dodaj opis zgłoszenia"
                      ),
                    )
                ),


              ),

              SizedBox(
                height: 16,
              ),

              Container(
                height: 50,
                child: (
                    ElevatedButton(
                      child: Text('Wyślij zgłoszenie'),
                      style: ElevatedButton.styleFrom(primary: Colors.blue),

                      onPressed: pickedFile == null ? null : () async {
                        setState(() {
                          isLoading = true;
                        });
                        ParseFileBase? parseFile;
                        if (kIsWeb) {
                          parseFile =
                              ParseWebFile(await pickedFile!.readAsBytes(),
                                  name: "image.jpg");
                        } else {
                          parseFile = ParseFile(File(pickedFile!.path));
                        }
                        final Dane = ParseObject('Foti')
                          ..set('file', parseFile);
                        await Dane.save();

                        doUserLogin();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },

                    )

                ),

              ),
            ],
          ),
        ));
  }

}

class Zgloszenie {
  final String id;
  final String nazwa;
  final String opis;
  final DateTime date;

  Zgloszenie({required this.id, required this.nazwa, required this.opis,required this.date});
}
class ZgloszenieListItem extends StatelessWidget {
  final Zgloszenie zgloszenie;

  const ZgloszenieListItem({required this.zgloszenie});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){},
      title: Text(zgloszenie.nazwa),
      subtitle: Text(zgloszenie.opis),



    );
  }
}



class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  List<Zgloszenie> zgloszenia = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Zgloszenie'));

    final response = await queryBuilder.query();

    final items = response.results?.map<Zgloszenie>((result) {
      final id = result.objectId!;
      final nazwa = result.get<String>('Kategoria')!;
      final opis = result.get<String>('Opis')!;
      final date = result.get<DateTime>('createdAt')!;

      return Zgloszenie(id: id, nazwa: nazwa, opis: opis, date: date);
    }).toList();

    setState(() {
      zgloszenia = items!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zgłoszenia'),
      ),
      body: ListView.builder(
        itemCount: zgloszenia.length,
        itemBuilder: (context, index) {
          final zgloszenie = zgloszenia[index];
          return ZgloszenieListItem(zgloszenie: zgloszenie);
        },
      ),
    );
  }

}




/*

  Future<List<ParseObject>> getGalleryList() async {
    QueryBuilder<ParseObject> queryZgloszenie =
    QueryBuilder<ParseObject>(ParseObject('Zgloszenie'))
      ..orderByAscending('createdAt');
    final ParseResponse apiResponse = await queryZgloszenie.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        reporting.addAll(apiResponse.results! as Iterable<ParseObject>);
      });
    } else {print(apiResponse.error?.message);
      return [];
    }
  }
 */

class Message {
  static void showSuccess(
      {required BuildContext context,
        required String message,
        VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showError(
      {required BuildContext context,
        required String message,
        VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

