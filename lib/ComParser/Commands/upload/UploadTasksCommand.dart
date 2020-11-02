import 'package:args/command_runner.dart';
import 'package:paulonia_scrum/ComParser/Options.dart';
import 'package:paulonia_scrum/controllers/UploadController.dart';
import 'package:paulonia_scrum/services/ConfigService.dart';

class UploadTasksCommand extends Command{

  @override
  final name = 'tasks';

  @override
  final description = 'Upload the task from the XML Paulonia Scrum file to the Backlog in the project repo and links the stories with the tasks';

  UploadTasksCommand(){
    argParser.addOption(
      Options.PROJECT,
      abbr: Options.PROJECT_ABBR, 
      help: '[Required] Set the project id. It needs the config file'
    );
  }

  void run(){
    if(argResults.arguments.isEmpty){
      usageException('Missing the input file: pscrum update backlog <file.xml> --project <projectId>');
    }
    String projectId = argResults[Options.PROJECT];
    if(projectId == null){
      usageException('Missing the project Id: pscrum update backlog <file.xml> --project <projectId>');
    }
    ConfigService.loadConfiguration(parent.argResults[Options.CONFIG]);
    UploadController.uploadTasks(argResults.arguments.first, projectId);
  }

}