import 'dart:collection';

import 'package:github/github.dart';
import 'package:paulonia_scrum/controllers/ConfigController.dart';
import 'package:paulonia_scrum/controllers/ScrumController.dart';
import 'package:paulonia_scrum/models/EpicModel.dart';
import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/services/github/GitHubService.dart';
import 'package:paulonia_scrum/utils/constants/ConfigConstants.dart';

class UploadController{

  /// Upload backlog
  static void uploadBacklog(
    String fileName,
    String projectId,
  ){
    ScrumController.loadScrum(fileName);
    _uploadProjectBacklog(projectId);
  }

  /// Upload the backlog in the [projectId]
  static Future<void> _uploadProjectBacklog(String projectId) async{
    ConfigController.verifyProjectConfig(projectId);
    Map<String, dynamic> project = ConfigController.getProject(projectId);
    var github = GitHub(auth: Authentication.withToken(
      project[ConfigConstants.API_KEY],
    ));
    List<EpicModel> epics = List.from(ScrumController.epics.values);
    List<StoryModel> stories = List.from(ScrumController.stories.values);
    epics.sort((a, b) => a.id.compareTo(b.id));
    stories.sort((a, b) => a.id.compareTo(b.id));
    RepositorySlug repositorySlug = RepositorySlug(
      project[ConfigConstants.REPO_USER_NAME],
      project[ConfigConstants.REPO_NAME],
    );
    HashMap<String, Issue> epicsIssuesMap = HashMap();
    HashMap<String, Issue> storyIssuesMap = HashMap();
    for(EpicModel epic in epics){
      epicsIssuesMap[epic.id] = await GitHubService.createEpic(
        github,
        repositorySlug,
        projectId,
        epic
      );
    }
    for(StoryModel story in stories){
      storyIssuesMap[story.id] = await GitHubService.createStory(
        github,
        repositorySlug,
        projectId,
        story
      );
    }
  }



}