import 'package:github/github.dart';
import 'package:paulonia_scrum/models/TaskModel.dart';

class StoryModel{

  String id;
  String epicId;
  String title;
  String description;
  List<String> dependencies;
  List<String> storiesThatDependsOf;
  List<TaskModel> tasks;
  Issue issue;

  StoryModel({
    this.id,
    this.epicId,
    this.title,
    this.description,
    this.dependencies,
    this.storiesThatDependsOf,
    this.tasks,
  });

}