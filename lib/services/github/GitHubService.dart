import 'dart:io';

import 'package:github/github.dart';
import 'package:paulonia_scrum/models/EpicModel.dart';
import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/utils/constants/Labels.dart';
import 'package:paulonia_scrum/utils/constants/TimeConstants.dart';

class GitHubService{

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
    StoryModel story, {
    bool verbose = true,  
  }) async{
    String issueTitle = story.id + ' - ' + story.title;
    Issue res = await gitHub.issues.create(
      repositorySlug,
      IssueRequest(
        title: issueTitle,
        labels: [projectId, LabelsConstants.STORY]
      ),
    );
    if(verbose) print('Created: ' + issueTitle + '#' + res.number.toString());
    sleep(Duration(milliseconds: TimeConstants.CREATE_DELAY_MILISECONDS));
    return res;
  }

}