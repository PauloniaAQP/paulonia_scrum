import 'package:args/command_runner.dart';
import 'package:paulonia_scrum/ComParser/Commands/upload/UploadBacklogCommand.dart';
import 'package:paulonia_scrum/ComParser/Commands/upload/UploadTasksCommand.dart';
import 'package:paulonia_scrum/ComParser/Options.dart';
import 'package:paulonia_scrum/utils/constants/NameConstants.dart';

class UploadCommand extends Command{

  @override
  final name = 'upload';

  @override
  final description = 'It makes a type of upload to GitHub';

  UploadCommand(){
    addSubcommand(UploadBacklogCommand());
    addSubcommand(UploadTasksCommand());
    argParser.addOption(
      Options.CONFIG,
      abbr: Options.CONFIG_ABBR,
      defaultsTo: NameConstants.CONFIG_FILE,
      help: "Set the configuration file, 'config.json' by default"
    );
  }


}