import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drawhelper/helpers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'drawing.dart';

void main(){
  runApp(const Draw());
}
class Draw extends StatelessWidget {
  const Draw({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController();
  var _isProcessing = false;
  dynamic _image;
  bool _isValidImageURL(String url) => Uri.parse(url).isAbsolute && lookupMimeType(url)?.split('/').first == 'image';

  _submit() async{
    final url = _urlController.text;
    if (!_isValidImageURL(url)) return h.showDialog(type: DialogType.ERROR, message: "Please enter valid image URL!");
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DrawingPage(background: url),),) as Uint8List?;
    if (!mounted || result == null) return;
    setState((){
      _image = result;
    });
  }

  _back(){
    setState((){
      _image = null;
    });
  }

  _save()async{
    setState((){
    _isProcessing = true;  
    });
    if (kIsWeb) {
      h.showToast("Uploading Image,Please wait");
      await Future.delayed(const Duration(milliseconds: 3000));
      h.showToast("Your image has been uploaded to server!");
    } else {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}";
      final filePath = await h.getDownloadPath('$fileName.png');
      final file = await File(filePath).writeAsBytes(_image);
      h.showToast("Your image has been saved in Download folder");
      h.shareFile(file.path, message: "Umm testo testo?");
    }
    setState((){
      _isProcessing = false;
      _image = null;
    });
  }

  @override
  void initState() {
    //_urlController.text = 'https://i.imgur.com/jiw5Da0.jpg';
    _urlController.text = 'https://i.imgur.com/4pkVNv2.jpg';
    h = MyHelper(context);
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _image != null ? null : AppBar(
        title: const Text("Draw Helper"),
        backgroundColor: Color(0xFF002B4D),
        centerTitle: true,
      ) ,
      body: SafeArea(
        child: Container(
          color: Color(0xFFADD8E6),
          child: _isProcessing ? const CircularProgressIndicator.adaptive():SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _image == null ? [
                const Text("Paste image URL here:", textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                TextField(controller: _urlController,textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                ElevatedButton(onPressed: _submit,style: ElevatedButton.styleFrom(primary: Color(0xFFFF002B4D)), child: const Text("Next"),),
              ] : [
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: _back,style: ElevatedButton.styleFrom(primary: Color(0xFFFF002B4D)), child: const Text("Back"))),
                    const SizedBox(width: 20,),
                    Expanded(child: ElevatedButton(onPressed: _save,style: ElevatedButton.styleFrom(primary: Color(0xFFFF002B4D)), child: const Text("Save"))),
                  ],
                ),
                const SizedBox(height: 20,),
                Image.memory(_image),
              ],
            ),
          ),
        ),
      ),
    );
  }
}