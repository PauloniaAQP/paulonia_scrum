import 'package:paulonia_scrum/ComParser/ComParser.dart';
import 'package:paulonia_scrum/utils/exceptions/NodeException.dart';

void run(List<String> arguments){
  try{
    ComParser.initParser();
    ComParser.run(arguments);
  }
  on NodeException catch(e){
    print(e.message);
  }
  
}








