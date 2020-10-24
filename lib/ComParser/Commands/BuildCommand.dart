import 'package:args/command_runner.dart';
import 'package:paulonia_scrum/ComParser/Commands/BuildIdCommand.dart';
import 'package:paulonia_scrum/ComParser/Options.dart';

class BuildCommand extends Command{

  @override
  final name = 'build';

  @override
  final description = 'It make a type of build with a XML Paulonia Scrum file';

  BuildCommand(){
    addSubcommand(BuildIdCommand());
    argParser.addOption(Options.OUTPUT, abbr: Options.OUTPUT_ABBR, defaultsTo: null);
  }

}
