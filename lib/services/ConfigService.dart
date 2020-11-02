import 'dart:convert';
import 'dart:io';

import 'package:paulonia_scrum/utils/constants/ConfigConstants.dart';
import 'package:paulonia_scrum/utils/exceptions/ConfigException.dart';

class ConfigService{

  static Map<String, dynamic> configMap;

  /// Loads the configuration file
  static void loadConfiguration(String configFile){
    final file = File(configFile);
    configMap = Map();
    if(!file.existsSync()) return;
    configMap = jsonDecode(file.readAsStringSync());
  }

  /// Gets the map of [projectId]
  static Map<String, dynamic> getProject(String projectId){
    _verifyProjectConfig(projectId);
    return configMap[ConfigConstants.PROJECT][projectId];
  }

  /// Verifies if exists [projectId] in the configuration and verifies its correct format
  static void _verifyProjectConfig(String projectId){
    if(!configMap.containsKey(ConfigConstants.PROJECT)){
      throw(ConfigException("Error in the config file: '" +
                          ConfigConstants.PROJECT + "' field is required"));
    }
    if(!configMap[ConfigConstants.PROJECT].containsKey(projectId)){
      throw(ConfigException("Error in the config file: '" + projectId +
                             "' it is not within the '" + ConfigConstants.PROJECT + "' field"));
    }
    Map<String, dynamic> project = configMap[ConfigConstants.PROJECT][projectId];
    if(!project.containsKey(ConfigConstants.REPO_USER_NAME)){
      throw(ConfigException("Error in the config file: '" + ConfigConstants.REPO_USER_NAME + 
                            "' field is required in '" + projectId + "'"));
    }
    if(!project.containsKey(ConfigConstants.REPO_NAME)){
      throw(ConfigException("Error in the config file: '" + ConfigConstants.REPO_NAME + 
                            "' field is required in '" + projectId + "'"));
    }
    if(!project.containsKey(ConfigConstants.API_KEY)){
      throw(ConfigException("Error in the config file: '" + ConfigConstants.API_KEY + 
                            "' field is required in '" + projectId + "'"));
    }
  }

}