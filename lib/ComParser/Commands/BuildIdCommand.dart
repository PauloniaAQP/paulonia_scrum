import 'package:args/command_runner.dart';
import 'package:paulonia_scrum/controllers/BuildController.dart';
import 'package:paulonia_scrum/ComParser/Options.dart';

class BuildIdCommand extends Command{

  @override
  final name = 'id';

  @override
  final description = 'Builds a new XML file with the epic and story IDs';

  BuildIdCommand();

  @override
  void run(){
    if(argResults.arguments.isEmpty){
      usageException('Missing the input file: pscrum build id <file.xml>');
    }
    BuildController.buildIds(
      argResults.arguments.first, 
      output: parent.argResults[Options.OUTPUT]
    );
  }



}