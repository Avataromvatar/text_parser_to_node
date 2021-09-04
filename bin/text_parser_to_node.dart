import 'dart:convert';
import 'dart:io';

import 'package:text_parser_to_node/simple_story_parser.dart';

/// <command> <command data> <command> <command data> ....
/// Command
/// -p path to file (default story.txt)
/// -t path to result file (default stdout)
Future<void> main(List<String> arguments) async {
  // print('Hello world! get ${arguments.length} arguments $arguments');
  _printHelp();
  String path = 'story.txt';
  String? target;
  bool _nextIsPath = false;
  bool _nextIsTarget = false;

  arguments.forEach((element) {
    //command data
   if (_nextIsPath) {
      _nextIsPath = false;
      path = element;
    }
    if (_nextIsTarget) {
      _nextIsTarget = false;
      target = element;
    }

    //commands
    if (element == '-p') _nextIsPath = true;
    if (element == '-t') _nextIsTarget = true;
    
  });

  if (await File(path).exists())
  {
    File f = File(path);
    var str = await f.readAsString();
    
    SimpleStoryParser parser = SimpleStoryParser();
    var ret = parser.parse(str);
    if(ret != null)
    { 
      var json = jsonEncode(ret); 
      print(json);
      if(target != null)
      {
        File t = File(target!);

        await t.writeAsString('$json');
      }
    }
  }else
  {
    print('Error: file $path not exists'); 
  } 
  
}

void _printHelp()
{
  print('<command> <command data> <command> <command data> ....');
  print('Command');
  print(' -p path to file (default story.txt)');
  print(' -t path to result file (save to json) (default just print)');
  print('example:dart text_parser_to_node.dart -t story.json \n\n');
}
