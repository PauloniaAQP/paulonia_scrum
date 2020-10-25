import 'package:paulonia_scrum/models/TaskModel.dart';

class StoryModel{

  String id;
  String title;
  String description;
  List<String> dependencies;
  List<String> storiesThatDependsOf;
  List<TaskModel> tasks;

  StoryModel({
    this.id,
    this.title,
    this.description,
    this.dependencies,
    this.storiesThatDependsOf,
    this.tasks,
  });

}