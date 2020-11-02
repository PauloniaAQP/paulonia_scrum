import 'dart:collection';

import 'package:github/github.dart';
import 'package:paulonia_scrum/models/TaskModel.dart';
import 'package:paulonia_scrum/services/ConfigService.dart';
import 'package:paulonia_scrum/services/ScrumService.dart';
import 'package:paulonia_scrum/models/EpicModel.dart';
import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/services/GitHubService.dart';
import 'package:paulonia_scrum/utils/constants/ConfigConstants.dart';

class UploadController{

  /// Upload the epics and stories from [fileName] into the [projectId] repository
  static Future<void> uploadBacklog(
    String fileName,
    String projectId,
  ) async{
    await ScrumService.loadScrum(fileName, getDependencies: true);
    return _uploadProjectBacklog(projectId);
  }

  /// Upload the tasks from the stories in [fileName] into the [projectId] repository
  static Future<void> uploadTasks(
    String fileName,
    String projectId,
  ) async{
    Map<String, dynamic> project = ConfigService.getProject(projectId);
    var github = GitHubService.getGitHubInstance(
      project[ConfigConstants.API_KEY]
    );
    RepositorySlug repositorySlug = RepositorySlug(
      project[ConfigConstants.REPO_USER_NAME],
      project[ConfigConstants.REPO_NAME],
    );
    await ScrumService.loadScrum(
      fileName,
      getStoriesIssueData: true,
      gitHub: github,
      repositorySlug: repositorySlug
    );
    return _uploadTasks(projectId, github, repositorySlug , project);
  }

  /// Upload the backlog in the [projectId]
  /// 
  /// This function upload the epics and stories issues to the Github
  /// repository with the id: [projectId]
  static Future<void> _uploadProjectBacklog(String projectId) async{
    Map<String, dynamic> project = ConfigService.getProject(projectId);
    var github = GitHubService.getGitHubInstance(
      project[ConfigConstants.API_KEY]
    );
    List<EpicModel> epics = List.from(ScrumService.epics.values);
    List<StoryModel> stories = List.from(ScrumService.stories.values);
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
        story,
        epicsIssuesMap[story.epicId].number
      );
    }
  }

  /// Uploads the tasks in projectId
  /// 
  /// Creates task issues from all task in the story list, also updates
  /// the story description with the task reference
  static Future<void> _uploadTasks(
    String projectId,
    GitHub github,
    RepositorySlug repositorySlug,
    Map<String, dynamic> project,
  ) async{
    List<StoryModel> stories = List.from(ScrumService.stories.values);
    HashMap<String, TaskModel> tasksMap = HashMap();
    for(StoryModel story in stories){
      for(TaskModel task in story.tasks){
        task.issue = await GitHubService.createTask(
          github,
          repositorySlug,
          projectId,
          task,
          ScrumService.stories[task.storyId].issue.number,
        );
        tasksMap[task.id] = task;
      }
      await GitHubService.updateTasksInStory(
        story,
        github,
        repositorySlug,
        story.tasks
      );
    }
  }

}