
///парсит строку преобразуя ее в List<dynamic> используя workers = [ dynamic Function(String formula) ]
///[command_BE] is array[2] what help parse command:
///     [0] - String begin command. default '[['
///     [1] - String end command. default ']]'
/// for example'[[style:bold]]' command style:bold send to workers
///
///[worker_BE] is array[2] what help detect worker and formula:
///     [0] - String begin command. default ''
///     [1] - String end command. default ':'
/// for example'[[style:bold]]' style - name worker bold -formula for worker
///
/// Fragment: 'Tell me [[style:bold]] why[[style:]]?'
/// 'Tell me ' - send to default workers. def_worker('Tell me ')
/// [[style:bold]] - execute workers['style'].call('bold')
/// ' why' - send to default workers. def_worker(' why')
/// [[style:]] - execute workers['style'].call('')
/// '?' - send to default workers. def_worker('?')
class StringCommandParser {
  List<String> _commandBE;
  List<String> _workerBE;
  dynamic Function(String formula, List<dynamic> list)? defaultHandler;

  ///обработчик
  late Map<String, dynamic Function(String formula, List<dynamic> list)>
      _handlers;

  ///обработчики команд
  Map<String, dynamic Function(String formula, List<dynamic> list)>
      get handlers => _handlers;
  void Function(String input)? inputNotification;

  ///оповещает когда приходит новая строка
  StringCommandParser(
      {List<String> commandBE = const ['[[', ']]'],
      List<String> workerBE = const ['', ':'],
      Map<String, dynamic Function(String formula, List<dynamic> list)>? userHandlers,
      this.inputNotification})
      : _commandBE = commandBE,
        _workerBE = workerBE,
        super() {
    if (userHandlers != null)
      _handlers = Map<
          String,
          dynamic Function(
              String formula, List<dynamic> list)>.from(userHandlers);
    else
      _handlers =
          Map<String, dynamic Function(String formula, List<dynamic> list)>();
    // handler = _main_worker;
    // startPipeline();
  }

  List<dynamic> parse(String input) {
    List<dynamic> retData = List<dynamic>.empty(growable: true);
    int indexCE = -1;
    int indexWorkerBegin = -1;
    int indexWorkerEnd = -1;
    // if(inputNotification!=null)
    inputNotification?.call(input);

    var partArray =
        input.split(_commandBE[0]); //рзбиваем все по начальному символу команды

    for (var i = 0; i < partArray.length; i++) {
      indexCE = partArray[i].indexOf(_commandBE[1]); //конец команды
      if (indexCE != -1) {
        indexWorkerBegin =
            _workerBE[0].length > 0 ? partArray[i].indexOf(_workerBE[0]) : 0;
        indexWorkerEnd = partArray[i].indexOf(_workerBE[1]);

        // String command = partArray[i].substring(0,partArray[i].indexOf(_command_BE[1]));
        String worker =
            partArray[i].substring(indexWorkerBegin, indexWorkerEnd);
        String formula = partArray[i]
            .substring(indexWorkerEnd + _workerBE[1].length, indexCE);
        if (_handlers.containsKey(worker)) {
          var tmp = _handlers[worker]!(formula,retData);
          if (tmp != null) retData.add(tmp);
        }
        retData.add(defaultHandler != null
            ? defaultHandler
                ?.call(partArray[i].substring(indexCE + _commandBE[1].length),retData)
            : partArray[i]);
      } else
        retData.add(defaultHandler != null
            ? defaultHandler?.call(partArray[i],retData)
            : partArray[i]);
    }

    return retData;
  }
}
