import 'dart:collection';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:paulonia_scrum/ComParser/Commands/BuildCommand.dart';
import 'package:paulonia_scrum/ComParser/Commands/UploadCommand.dart';
import 'package:paulonia_scrum/ComParser/Options.dart';
import 'package:paulonia_scrum/utils/constants/NameConstants.dart';

class ComParser{

  static final _runner = CommandRunner('pscrum', 'Paulonia Scrum');

  static void initParser(){
    _runner.addCommand(BuildCommand());
    _runner.addCommand(UploadCommand());
  }

  static void run(List<String> arguments){
    _runner.run(arguments);
  }

}


class CommandParser{

  ArgParser parser;
  HashMap<String, CommandParser> commands = HashMap();

  CommandParser(
    this.parser,
  );

  void addCommand(String commandName){
    commands[commandName] =  CommandParser(
      parser.addCommand(commandName),
    );
  }

}