import 'dart:io';

import 'package:github/github.dart';
import 'package:paulonia_scrum/models/EpicModel.dart';
import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/models/TaskModel.dart';
import 'package:paulonia_scrum/services/ContentService.dart';
import 'package:paulonia_scrum/utils/constants/GitHubConstants.dart';
import 'package:paulonia_scrum/utils/constants/Labels.dart';
import 'package:paulonia_scrum/utils/constants/TimeConstants.dart';

class GitHubService{

  /// Gets a new GitHub instance from an [apiKey]
  static GitHub getGitHubInstance(String apiKey){
    return GitHub(auth: Authentication.withToken(
      apiKey,
    ));
  }

  /// Creates an epic on github in [projectId]
  static Future<Issue> createEpic(
    GitHub gitHub,
    RepositorySlug repositorySlug,
    String projectId,
    EpicModel epic, {
    bool verbose = true,
  }) async{
    String issueTitle = epic.id + ' - ' + epic.title;
    Issue res = await gitHub.issues.create(
      repositorySlug,
      IssueRequest(
        title: issueTitle,
        labels: [projectId, LabelsConstants.EPIC]
      ),
    );
    if(verbose) print('Created: ' + issueTitle + ' #' + res.number.toString());
    sleep(Duration(milliseconds: TimeConstants.CREATE_DELAY_MILISECONDS));
    return res;
  }

  /// Creates a story on github in [projectId]
  static Future<Issue> createStory(
    GitHub gitHub,
    RepositorySlug repositorySlug,
    String projectId,
    StoryModel story, 
    int epicIssueNum, {
    bool verbose = true,  
  }) async{
    String issueTitle = story.id + ' - ' + story.title;
    Issue res = await gitHub.issues.create(
      repositorySlug,
      IssueRequest(
        title: issueTitle,
        labels: [projectId, LabelsConstants.STORY],
        body: ContentService.makeStoryContent(story, epicIssueNum),
      ),
    );
    if(verbose) print('Created: ' + issueTitle + ' #' + res.number.toString());
    sleep(Duration(milliseconds: TimeConstants.CREATE_DELAY_MILISECONDS));
    return res;
  }

  /// Creates a task on github in [projectId]
  /// 
  /// Set [milestoneNumber] to set a mileston to the created task
  static Future<Issue> createTask(
    GitHub gitHub,
    RepositorySlug repositorySlug,
    String projectId,
    TaskModel task,
    int storyIssueNum, {
    bool verbose = true,
    int milestoneNumber,  
  }) async{
    IssueRequest request = IssueRequest(
      title: task.title,
      labels: [projectId, LabelsConstants.TASK],
      body: ContentService.makeTaskContent(task, storyIssueNum),
    );
    if(milestoneNumber != null) request.milestone = milestoneNumber;
    Issue res = await gitHub.issues.create(
      repositorySlug,
      request,
    );
    if(verbose) print('Created: ' + task.title + ' #' + res.number.toString());
    return res;
  }

  /// Creates a Milestone in the actual project
  static Future<Milestone> createMiliestone(
    GitHub gitHub,
    RepositorySlug repositorySlug,
    String title, {
    String description,
    DateTime dueOn,  
    bool verbose = true,  
  }) async{
    Milestone res = await gitHub.issues.createMilestone(
      repositorySlug,
      CreateMilestone(
        title,
        description: description,
        dueOn: dueOn
      ),
    );
    if(verbose) print('Milestone created: ' + title);
    return res;
  }

  /// Update the tasks section in the Story body
  /// 
  /// Set [milestoneNumber] to update the linked milestone ofthe story
  static Future<Issue> updateTasksInStory(
    StoryModel story,
    GitHub gitHub,
    RepositorySlug repositorySlug,
    List<TaskModel> tasks, {
    bool verbose = true,
    int milestoneNumber,
  }) async {
    IssueRequest request = IssueRequest(
      body: ContentService.replaceTaskSectionInStoryContent(story.issue.body, tasks),
    );
    if(milestoneNumber != null) request.milestone = milestoneNumber;
    Issue res = await gitHub.issues.edit(
      repositorySlug,
      story.issue.number,
      request
    );
    if(verbose) print('Updated: ' + story.title + ' #' + res.number.toString());
    return res;
  }

  /// Gets the open stories of [repositorySlug]
  static Future<List<Issue>> getOpenStories(
    GitHub gitHub,
    RepositorySlug repositorySlug,
  ) async{
    return await gitHub.issues.listByRepo(
      repositorySlug,
      state: GitHubConstants.OPEN_ISSUE_STATE,
      labels: [LabelsConstants.STORY],
    ).toList();
  } 

}