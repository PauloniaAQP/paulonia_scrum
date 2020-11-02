import 'package:github/github.dart';

class TaskModel{

  String id;
  String storyId;
  String title;
  double estimatedHours;
  String assignedUserId;
  Issue issue;

  TaskModel({
    this.title,
    this.storyId,
    this.estimatedHours,
    this.assignedUserId,
  });

}