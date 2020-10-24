import 'dart:io';

import 'package:xml/xml.dart';

class Utils{

  /// Gets the part without the extension of a file name
  static String getFileName(String fileName){
    return fileName.split('.').first;
  }

  /// Open a XML document
  static XmlDocument openDocument(String fileName){
    final file = File(fileName);
    final document = XmlDocument.parse(file.readAsStringSync());
    return document;
  }

  /// Saves a document
  static void saveDocument(String output, String content){
    final file = File(output);
    file.createSync();
    file.writeAsStringSync(content);
  }

}