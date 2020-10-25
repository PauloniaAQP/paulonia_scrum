import 'package:paulonia_scrum/models/StoryModel.dart';

class EpicModel{

  String id;
  String title;
  List<StoryModel> stories;

  EpicModel({
    this.id,
    this.title,
    this.stories,
  });

}