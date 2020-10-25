import 'dart:collection';

import 'package:paulonia_scrum/controllers/BuildController.dart';
import 'package:paulonia_scrum/models/EpicModel.dart';
import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/models/TaskModel.dart';
import 'package:paulonia_scrum/utils/constants/AttributeNames.dart';
import 'package:paulonia_scrum/utils/constants/NameConstants.dart';
import 'package:paulonia_scrum/utils/constants/TagNames.dart';
import 'package:paulonia_scrum/utils/exceptions/NodeException.dart';
import 'package:paulonia_scrum/utils/utils.dart';
import 'package:xml/xml.dart';

class ScrumController{

  static HashMap<String, EpicModel> epics;
  static HashMap<String, StoryModel> stories;

  /// Load all data about epics, stories and tasks
  static void loadScrum(String fileName){
    epics = HashMap();
    stories = HashMap();
    XmlDocument document = Utils.openDocument(fileName);
    if(!_verifyIds(document)){
      BuildController.buildIds(fileName, output: NameConstants.TEMP_ID_XML_FILE);
      document = Utils.openDocument(NameConstants.TEMP_ID_XML_FILE);
    }
    _loadEssencialData(document);
    _loadDependencies();
  }

  /// It verifies if epics and stories in [document] have IDs
  static bool _verifyIds(XmlDocument document){
    var _epics = document.findAllElements(TagNames.EPIC_TAG);
    for(XmlNode epic in _epics){
      if(epic.getAttribute(AttributeNames.ID_ATTRIBUTE) == null){
        return false;
      }
    }
    var _stories = document.findAllElements(TagNames.STORY_TAG);
    for(XmlNode story in _stories){
      if(story.getAttribute(AttributeNames.ID_ATTRIBUTE) == null){
        return false;
      }
    }
    return true;
  }

  /// Loads the essencial data from epics, stories and tasks
  static void _loadEssencialData(XmlDocument document){
    var _epics = document.findAllElements(TagNames.EPIC_TAG);
    String epicId;
    String storyId;
    for(XmlNode epic in _epics){
      epicId = epic.getAttribute(AttributeNames.ID_ATTRIBUTE);
      epics[epicId] = EpicModel(
        id: epicId,
        title: Utils.getNodeContent(
          epic,
          TagNames.TITLE_TAG,
          required: true,
          errorMsg: "Error in the epic tag: '" + epicId + "', <title> is required",
        ),
      );
      List<StoryModel> _storiesList = List();
      var _stories = epic.findAllElements(TagNames.STORY_TAG);
      for(XmlNode story in _stories){
        storyId = story.getAttribute(AttributeNames.ID_ATTRIBUTE);
        stories[storyId] = StoryModel(
          id: storyId,
          title: Utils.getNodeContent(
            story,
            TagNames.TITLE_TAG,
            required: true,
            errorMsg: "Error in the story tag: '" + storyId + "', <title> is required",
          ),
          description: Utils.getNodeContent(story, TagNames.DESCRIPTION_TAG),  
        );
        var _tasks = story.findAllElements(TagNames.TASK_TAG);
        List<TaskModel> _taskList = List();
        for(XmlNode task in _tasks){
          String _title = Utils.eraseTags(task.toXmlString(pretty: true), TagNames.TASK_TAG);
          if(_title.isNotEmpty){
            _taskList.add(TaskModel(
              title: _title,
            ));
          }
        }
        stories[storyId].tasks = _taskList;
        List<String> _dependenciesList = List();
        var _dependencies = story.findAllElements(TagNames.DEPENDENCY_TAG);
        for(XmlNode dependency in _dependencies){
          String _id = Utils.eraseTags(dependency.toXmlString(pretty: true), TagNames.DEPENDENCY_TAG);
          if(_id.isNotEmpty){
            _dependenciesList.add(_id);
          }
        }
        stories[storyId].dependencies = _dependenciesList;
        stories[storyId].storiesThatDependsOf = List();
        _storiesList.add(stories[storyId]);
      }
      epics[epicId].stories = _storiesList;
    }
  }

  /// Load all dependencies of all stories and verifies if the dependencies IDs are correct
  /// 
  /// * This function needs [_loadEssencialData()] has been called previously
  static void _loadDependencies(){
    stories.forEach((storyId, story) {
      story.dependencies.forEach((element) {
        if(!stories.containsKey(element)){
          throw(NodeException("Error in the story '" + storyId + 
              "' the dependency story '" + element + "' doesn't exist"));
        }
        stories[element].storiesThatDependsOf.add(storyId);
      });
    });
  }

}