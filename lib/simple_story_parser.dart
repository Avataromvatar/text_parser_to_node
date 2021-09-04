import 'package:text_parser_to_node/string_command_parser.dart';

class SimpleStoryParser
{
  late StringCommandParser _parser;
  List<Map<String,dynamic>> _data = List<Map<String,dynamic>>.empty(growable: true);
  Map<String,dynamic>? _current;

  SimpleStoryParser()
  {
    _parser = StringCommandParser(commandBE: [
      '[#',
      '#]'
    ], userHandlers: {
      'link': _link,
      'fragment': _fragment,
    });
    _parser.defaultHandler = _default;
  }

  List<Map<String,dynamic>>? parse(String text)
  {
    _data.clear();
    var tmp =_parser.parse(text);
    
    if(_current!=null)
    {
       _data.add(_current!);
    }

    return _data;
  } 

dynamic _default(String formula, List<dynamic> list) {
    if(_current!=null)
    {
      _current!['text'] = _current!['text'] + formula;
    }
    return null;
  }
  dynamic _link(String formula, List<dynamic> list) {
    if (_current != null) {
      _current!['links'].add(formula);
    }
    return null;
  }
  dynamic _fragment(String formula, List<dynamic> list) {
    if(_current==null)
    {
      _current = {'name':formula,'text':'','links':[]};
    }
    else
    {
      _data.add(Map < String, dynamic >.from(_current!));
      _current = {'name': formula, 'text': '', 'links': []};  
    }
    
    return null;
  }
  

}