part of z_console;

/** A basic console provider with word-wrap support. */
class ConsoleProvider implements IOProvider
{
  final Stdin textStream = stdin;
  final List<String> lineBuffer = new List<String>();
  final List<String> outputBuffer = new List<String>();

  final int cols = 80;

  ConsoleProvider();

  Future<Object> command(String JSONCommand){
    var c = new Completer();

    var msgSet = JSON.decode(JSONCommand);

    var cmd = IOCommands.toIOCommand(msgSet[0]);

    switch(cmd){

    //print('msg received>>> $cmd');    switch(cmd){
      case IOCommands.PRINT:
        output(msgSet[1], msgSet[2]);
        c.complete(null);
        break;
      case IOCommands.STATUS:
        print('(${msgSet})\n');
        c.complete(null);
        break;
      case IOCommands.READ:
        getLine().then((line) => c.complete(line));
        break;
      case IOCommands.READ_CHAR:
        getChar().then((char) => c.complete(char));
        break;
      case IOCommands.SAVE:
        saveGame(msgSet.getRange(1, msgSet.length - 1))
          .then((result) => c.complete(result));
        break;
      case IOCommands.CLEAR_SCREEN:
        //no clear console api, so
        //we just print a bunch of lines
        for(int i=0; i < 50; i++){
         print('');
        }
        c.complete(null);
        break;
      case IOCommands.RESTORE:
        restore().then((result) => c.complete(result));
        break;
      case IOCommands.PRINT_DEBUG:
        print('${msgSet[1]}');
        c.complete(null);
        break;
      case IOCommands.QUIT:
        print('Zart: Game Over!');
        c.complete(null);
        exit(1);
        break;
      default:
        //print('Zart: ${cmd}');
        c.complete(null);
    }

    return c.future;
  }



  Future<bool> saveGame(List<int> saveBytes){
    var c = new Completer();
    print('(Caution: will overwrite existing file!)');
    print('Enter file name to save to (no extension):');

    textStream
        .transform(UTF8.decoder)
        .transform(const LineSplitter())
        .listen((fn) {
      if (fn == null || fn.isEmpty)
      {
        print('Invalid file name given.');
        c.complete(false);
      }else{
        try{
          print('Saving game "${fn}.sav".  Use "restore" to restore it.');
          File f2 = new File('games${Platform.pathSeparator}${fn}.sav');
          IOSink s = f2.openWrite();
          s.write(saveBytes);
          s.close();
          c.complete(true);
        }on FileSystemException catch(e){
          print('File IO error.');
          c.complete(false);
        }
      }
    });
    return c.future;
  }

  Future<List<int>> restore(){
    var c = new Completer();
    print('Enter game file name to load (no extension):');

    textStream
        .transform(UTF8.decoder)
        .transform(const LineSplitter())
        .listen((fn) {
      if (fn == null || fn.isEmpty)
      {
        print('Invalid file name given.');
        c.complete(null);
      }else{
        try{
          print('Restoring game "${fn}.sav"...');
          File f2 = new File('games${Platform.pathSeparator}${fn}.sav');
          c.complete(f2.readAsBytesSync());
        }on FileSystemException catch(e){
          print('File IO error.');
          c.complete(null);
        }
      }
    });

    return c.future;
  }

  void output(int windowID, String text) {
    if (text.startsWith('["STATUS",') && text.endsWith(']')){
      //ignore status line for simple console games
      return;
    }
    var lines = text.split('\n');
    for(final l in lines){
      var words = new List<String>.from(l.split(' '));

      var s = new StringBuffer();
      while(!words.isEmpty){
        var nextWord = words.removeAt(0);

        if (s.length > cols){
          outputBuffer.insert(0, '$s');
          print('$s');
          s = new StringBuffer();
          s.write('$nextWord ');
        }else{
          if (words.isEmpty){
            s.write('$nextWord ');
            outputBuffer.insert(0, '$s');
            print('$s');
            s = new StringBuffer();
          }else{
            s.write('$nextWord ');
          }
        }
      }

      if (s.length > 0){
        outputBuffer.insert(0, '$s');
        print('$s');
        s = new StringBuffer();
      }
    }
  }

  void DebugOutput(String text) => print(text);

  Future<String> getChar(){
    var c = new Completer();

    if (!lineBuffer.isEmpty){
      c.complete(lineBuffer.removeLast());
    }else{
      //flush?
      textStream
          .transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen((line) {
        if (line == null){
          c.complete('');
        }else{
          if (line == ''){
            c.complete('\n');
          }else{
            c.complete(line[0]);
          }
        }
      });
    }

    return c.future;
  }

  Future<String> getLine(){
    Completer c = new Completer();

    if (!lineBuffer.isEmpty){
      c.complete(lineBuffer.removeLast());
    }else{
      textStream
          .transform(UTF8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line == null){
          c.complete('');
        }else{
          if (line == ''){
            c.complete('\n');
          }else{
            c.complete(line);
          }
        }
      });
    }

    return c.future;
  }
}
