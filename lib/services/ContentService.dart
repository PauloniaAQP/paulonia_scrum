import 'package:paulonia_scrum/models/StoryModel.dart';
import 'package:paulonia_scrum/models/TaskModel.dart';
import 'package:paulonia_scrum/utils/constants/ContentConstants.dart';

class ContentService{

  /// Builds and gets the body content of a new story
  static String makeStoryContent(StoryModel story, int epicIssueNum){
    String content = '';
    if(story.description != null && story.description.isNotEmpty){
      content += story.description + '\n\n';
    }
    content += 'Epic: #' + epicIssueNum.toString() + '\n\n';
    content += ContentConstants.INIT_SECTION_TAG + '\n';
    content += ContentConstants.TASKS_SECTION_TAG + '\n';
    content += ContentConstants.SECTION_PREFIX + ' ' + ContentConstants.GENERAL_TASK_SECTION_TITLE +  '\n\n';
    if(story.tasks.isEmpty){
      content += 'Nothing to show\n\n';
    }
    else{
      for(TaskModel task in story.tasks){
        content += '- ' + task.title + '\n';
      }
      content += '\n';
    }
    return content;
  }

  /// Build and gets the body content of a new task
  static String makeTaskContent(TaskModel task, int storyIssueNum){
    String content = '';
    content += 'Story: #' + storyIssueNum.toString();
    return content;
  }

  /// Replaces the ans [body] of a story and adds the [tasks] with issue references
  static String replaceTaskSectionInStoryContent(String body, List<TaskModel> tasks){
    String content = '';
    List<String> sections = body.split(ContentConstants.INIT_SECTION_TAG + '\n');
    String section = '';
    for(int i = 0; i < sections.length; i++){
      section = sections[i];
      if(i == 0){
       content += section + ContentConstants.INIT_SECTION_TAG + '\n';
       continue;
      }
      if(section.split('\n').first.trim() == ContentConstants.TASKS_SECTION_TAG){
        content += ContentConstants.TASKS_SECTION_TAG + '\n';
        content += ContentConstants.SECTION_PREFIX + ' ' + ContentConstants.GENERAL_TASK_SECTION_TITLE +  '\n\n';
        for(TaskModel task in tasks){
          content += '- [ ] ' + task.title + ' #' + task.issue.number.toString() + '\n';
        }
        content += '\n';
      }
      else{
        content += section;
      } 
      if(i + 1 != sections.length){
        content += ContentConstants.INIT_SECTION_TAG + '\n';
      }
    }
    return content;
  }

  /// Gets the epic/story id from an issue title
  /// 
  /// getIdFromTitle('S1 - Frist story') => 'S1'
  static String getIdFromTitle(String issueTitle){
    return issueTitle.split('-').first.trim();
  }


}