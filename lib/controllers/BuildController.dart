import 'package:paulonia_scrum/utils/constants/AttributeNames.dart';
import 'package:paulonia_scrum/utils/constants/IdConstants.dart';
import 'package:paulonia_scrum/utils/constants/NameConstants.dart';
import 'package:paulonia_scrum/utils/constants/TagNames.dart';
import 'package:paulonia_scrum/utils/utils.dart';
import 'package:xml/xml.dart';

class BuildController{

  /// Creates a new XML document with the epic and story ids
  /// 
  /// Set [output] to save the result in output file. By default 
  /// the output file is [fileName]_id.xml
  static void buildIds(String fileName, {String output}){
    if(output == null){
      output = Utils.getFileName(fileName) + NameConstants.ID_XML_FILE;
    }
    XmlDocument document = Utils.openDocument(fileName);
    final epics = document.findAllElements(TagNames.EPIC_TAG);
    String id;
    int index = 1;
    int secondIndex = 1;
    var stories;
    for(XmlNode node in epics){
      id = IdConstants.EPIC_ID_PREFIX + index.toString();
      node.setAttribute(AttributeNames.ID_ATTRIBUTE, id);
      stories = node.findAllElements(TagNames.STORY_TAG);
      secondIndex = 1;
      for(XmlNode story in stories){
        id = IdConstants.STORY_ID_PREFIX + index.toString() + '.' + secondIndex.toString();
        story.setAttribute(AttributeNames.ID_ATTRIBUTE, id);
        secondIndex++;
      }
      index++;
    }
    Utils.saveDocument(output, document.toXmlString());
  }

  static void des(String fileName){
    XmlDocument document = Utils.openDocument(fileName);
    final epics = document.findAllElements(TagNames.EPIC_TAG);
    final stories = epics.first.findAllElements(TagNames.STORY_TAG);
    String content = stories.first.getElement(TagNames.DESCRIPTION_TAG).toXmlString(pretty: true);
    print(Utils.eraseTags(content, TagNames.DESCRIPTION_TAG));
  }

}