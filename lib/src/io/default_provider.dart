part of zart_prujohn;

/**
* Default provider with word-wrap support.
*
* Cannot take input because it has no io
* context.  Also cannot provide async facility
* so just runs sync.
*
*/
class DefaultProvider implements IOProvider
{
  final List<String> script;
  final int cols = 80;

  DefaultProvider(Iterable<String> script)
  :
    script = new List<String>.from(script);


  Future<Object> command(String JSONCommand) {
    // FIXME(cbracken) should this be abstract?
  }

  Future<bool> saveGame(List<int> saveBytes){
    print('Save not supported with this provider.');
    var c = new Completer();
    c.complete(false);
    return c.future;
  }

  Future<List<int>> restore(){
    print('Restore not supported with this provider.');
    var c = new Completer();
    c.complete(null);
    return c.future;
  }

  void PrimaryOutput(String text) {
    var lines = text.split('\n');
    for(final l in lines){
      var words = new List<String>.from(l.split(' '));

      var s = new StringBuffer();
      while(!words.isEmpty){
        var nextWord = words.removeAt(0);

        if (s.length > cols){
          print('$s');
          s = new StringBuffer();
          s.write('$nextWord ');
        }else{
          if (words.isEmpty){
            s.write('$nextWord ');
            print('$s');
            s = new StringBuffer();
          }else{
            s.write('$nextWord ');
          }
        }
      }

      if (s.length > 0){
        print('$s');
        s = new StringBuffer();
      }
    }
  }

  void DebugOutput(String text) => print(text);

  Future<String> getLine(){
    Completer c = new Completer();

    if (!script.isEmpty){
      c.complete(script.removeAt(0));
    }

    return c.future;
  }
}