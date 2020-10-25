import 'dart:io';

import 'package:paulonia_scrum/utils/exceptions/NodeException.dart';
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

  /// Erase the open and close [tag] from a content
  /// 
  /// eraseTags('<tag>Content</tag>') => 'Content'
  static String eraseTags(String content, String tag){
    String initTag = '<' + tag + '>';
    String endTag = '</' + tag + '>';
    String res = content.replaceFirst(initTag, '');
    res = res.replaceFirst(endTag, '');
    return res;
  }

  /// Gets the content of a [elementName] insede a [node] in a correct format
  static String getNodeContent(
    XmlNode node,
    String elementName, {
    bool required = false,
    String errorMsg,
  }){
    XmlNode newNode = node.getElement(elementName);
    if(newNode == null){
      if(required){
        if(errorMsg == null){
          errorMsg = "Error getting the node: '" + elementName + "'";
        } 
        throw(NodeException(errorMsg));
      }
      return '';
    } 
    String content = newNode.toXmlString(pretty: true);
    return eraseTags(content, elementName);
  }

}