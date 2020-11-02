import 'dart:collection';

import 'package:github/github.dart';
import 'package:paulonia_scrum/controllers/BuildController.dart';
import 'package:paulonia_scrum/models/EpicModel.dart';
import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/models/TaskModel.dart';
import 'package:paulonia_scrum/services/ContentService.dart';
import 'package:paulonia_scrum/services/GitHubService.dart';
import 'package:paulonia_scrum/utils/constants/AttributeNames.dart';
import 'package:paulonia_scrum/utils/constants/NameConstants.dart';
import 'package:paulonia_scrum/utils/constants/TagNames.dart';
import 'package:paulonia_scrum/utils/exceptions/NodeException.dart';
import 'package:paulonia_scrum/utils/utils.dart';
import 'package:xml/xml.dart';

class ScrumService{

  static HashMap<String, EpicModel> _epics;
  static HashMap<String, StoryModel> _stories;
  static HashMap<int, StoryModel> _storiesByIssueNumber;
  static HashMap<String, EpicModel> get epics => _epics;
  static HashMap<String, StoryModel> get stories => _stories;
  static HashMap<int, StoryModel> get storiesByIssueNumber => _storiesByIssueNumber;

  /// Load all data about epics, stories and tasks
  static Future<void> loadScrum(
    String fileName, {
    bool getDependencies = false,  
    bool getStoriesIssueData = false,
    GitHub gitHub,
    RepositorySlug repositorySlug,
  }) async{
    _epics = HashMap();
    _stories = HashMap();
    XmlDocument document = Utils.openDocument(fileName);
    if(!_verifyIds(document)){
      BuildController.buildIds(fileName, output: NameConstants.TEMP_ID_XML_FILE);
      document = Utils.openDocument(NameConstants.TEMP_ID_XML_FILE);
    }
    _loadEssencialData(document);
    if(getDependencies) _loadDependencies();
    if(getStoriesIssueData) await _loadStoriesIssues(gitHub, repositorySlug);
  }

  /// It verifies if epics and stories in [document] have IDs
  static bool _verifyIds(XmlDocument document){
    var __epics = document.findAllElements(TagNames.EPIC_TAG);
    for(XmlNode epic in __epics){
      if(epic.getAttribute(AttributeNames.ID_ATTRIBUTE) == null){
        return false;
      }
    }
    var __stories = document.findAllElements(TagNames.STORY_TAG);
    for(XmlNode story in __stories){
      if(story.getAttribute(AttributeNames.ID_ATTRIBUTE) == null){
        return false;
      }
    }
    return true;
  }

  /// Loads the essencial data from epics, stories and tasks from a XML document
  static void _loadEssencialData(XmlDocument document){
    var __epics = document.findAllElements(TagNames.EPIC_TAG);
    String epicId;
    String storyId;
    for(XmlNode epic in __epics){
      epicId = epic.getAttribute(AttributeNames.ID_ATTRIBUTE);
      _epics[epicId] = EpicModel(
        id: epicId,
        title: Utils.getNodeContent(
          epic,
          TagNames.TITLE_TAG,
          required: true,
          errorMsg: "Error in the epic tag: '" + epicId + "', <title> is required",
        ),
      );
      List<StoryModel> _storiesList = List();
      var __stories = epic.findAllElements(TagNames.STORY_TAG);
      for(XmlNode story in __stories){
        storyId = story.getAttribute(AttributeNames.ID_ATTRIBUTE);
        _stories[storyId] = StoryModel(
          id: storyId,
          epicId: epicId,
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
              storyId: storyId,
            ));
          }
        }
        _stories[storyId].tasks = _taskList;
        List<String> _dependenciesList = List();
        var _dependencies = story.findAllElements(TagNames.DEPENDENCY_TAG);
        for(XmlNode dependency in _dependencies){
          String _id = Utils.eraseTags(dependency.toXmlString(pretty: true), TagNames.DEPENDENCY_TAG);
          if(_id.isNotEmpty){
            _dependenciesList.add(_id);
          }
        }
        _stories[storyId].dependencies = _dependenciesList;
        _stories[storyId].storiesThatDependsOf = List();
        _storiesList.add(stories[storyId]);
      }
      _epics[epicId].stories = _storiesList;
    }
  }

  /// Load all dependencies of all stories and verifies if the dependencies IDs are correct
  /// 
  /// * This function needs [_loadEssencialData()] has been called previously
  static void _loadDependencies(){
    _stories.forEach((storyId, story) {
      story.dependencies.forEach((element) {
        if(!_stories.containsKey(element)){
          throw(NodeException("Error in the story '" + storyId + 
              "' the dependency story '" + element + "' doesn't exist"));
        }
        _stories[element].storiesThatDependsOf.add(storyId);
      });
    });
  }

  /// Loads the issue of the stories in [_stories]
  static Future<void> _loadStoriesIssues(
    GitHub gitHub,
    RepositorySlug repositorySlug
  ) async{
    List<Issue> storyIssues = await GitHubService.getOpenStories(gitHub, repositorySlug);
    String id;
    _storiesByIssueNumber = HashMap();
    for(Issue issue in storyIssues){
      id = ContentService.getIdFromTitle(issue.title);
      if(_stories.containsKey(id)){
        _stories[id].issue = issue;
        _storiesByIssueNumber[issue.number] = _stories[id];
      }
    }
  }

}