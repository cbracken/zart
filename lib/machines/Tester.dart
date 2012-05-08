
/**
* A disassembler of z-machine code using visitor pattern.
*/
class Tester implements IMachine
{
  Map<String, Function> ops;
  
  Tester()
  {
    ops = 
      {
       '224' : visitOperation_callvs
      };
  }
    
  
  ZVersion get version() => ZVersion.S;

  int get maxFileLength() => 128;

  int unpack(int packedAddr){
    return packedAddr * 2;
  }

  int fileLengthMultiplier() => 2;


  visitHeader(){
    Z.mem.abbrAddress = Z.mem.loadw(Header.ABBREVIATIONS_TABLE_ADDR);
    Z.mem.objectsAddress = Z.mem.loadw(Header.OBJECT_TABLE_ADDR);
    Z.mem.globalVarsAddress = Z.mem.loadw(Header.GLOBAL_VARS_TABLE_ADDR);
    Z.mem.staticMemAddress = Z.mem.loadw(Header.STATIC_MEM_BASE_ADDR);
    Z.mem.dictionaryAddress = Z.mem.loadw(Header.DICTIONARY_ADDR);
    Z.mem.highMemAddress = Z.mem.loadw(Header.HIGHMEM_START_ADDR);

    Z.pc = Z.mem.loadw(Header.PC_INITIAL_VALUE_ADDR);

    out('Disassembly');
    out('-----------');
    out('(Story contains ${Z.mem.size} bytes.)');
    out('');
    out('------- START HEADER -------');
    out('Z-Machine Version: ${Z.version}');
    out('Flags1(binary): ${Z.mem.loadw(Header.FLAGS1).toRadixString(2)}');
    // word after flags1 is used by Inform
    out('Abbreviations Location: ${Z.mem.abbrAddress.toRadixString(16)}');
    out('Object Table Location: ${Z.mem.objectsAddress.toRadixString(16)}');
    out('Global Variables Location: ${Z.mem.globalVarsAddress.toRadixString(16)}');
    out('Static Memory Start: ${Z.mem.staticMemAddress.toRadixString(16)}');
    out('Dictionary Location: ${Z.mem.dictionaryAddress.toRadixString(16)}');
    out('High Memory Start: ${Z.mem.highMemAddress.toRadixString(16)}');
    out('Program Counter Start: ${Z.pc.toRadixString(16)}');
    out('Flags2(binary): ${Z.mem.loadb(Header.FLAGS2).toRadixString(2)}');
    out('Length Of File: ${Z.mem.loadw(Header.LENGTHOFFILE) * fileLengthMultiplier()}');
    out('Checksum Of File: ${Z.mem.loadw(Header.CHECKSUMOFFILE)}');
    //TODO v4+ header stuff here
    out('Standard Revision: ${Z.mem.loadw(Header.REVISION_NUMBER)}');
    out('-------- END HEADER ---------');

    out('');
    out('pc initial addr: ${Z.pc}, value: ${Z.mem.loadb(Z.pc)}');
    out('hmm: ${Z.mem.getRange(Z.pc, 10)}');


    out('first 10: ${Z.mem.getRange(0, 10)}');
    out('prove variable (should be 3): ${Z.mem.loadb(Z.pc) >> 6}');
  }

  visitInstruction(int i){
    if (ops.containsKey('$i')){
      var func = ops['$i'];
      func();
    }else{
      throw new Exception('Unsupported Op Code: $i');
    }
  }

  visitOperation_callvs(){
    out('call_vs (variable operands)');
    var op = new CallVS();
    op.visit(this);
  }
    
  List<Operand> visitOperands(int howMany, bool isVariable){
    var operands = isVariable ? new List<Operand>() : new List<Operand>(howMany);
    
    //load operand types
    var shiftStart = howMany > 4 ? 14 : 6;
    var os = howMany > 4 ? Z.readw() : Z.readb();
    
    while(shiftStart > -2){
      var to = os >> shiftStart; //shift
      to &= 3; //mask higher order bits we don't care about
      if (to == OperandType.OMITTED){
        break;
      }else{
        operands.add(new Operand(to));
        if (operands.length == howMany) break;
        shiftStart -= 2;
      }
    }

    //load values
    operands.forEach((Operand o){
      switch (o.type){
        case OperandType.LARGE:
          o.value = Z.readw();
          break;
        case OperandType.SMALL:
          o.value = Z.readb();
          break;
        case OperandType.VARIABLE:
          throw const NotImplementedException();
        default:
          throw new Exception('Illegal Operand Type found: ${o.type.toRadixString(16)}');
      }
    });
    
    out('  ${operands.length} operands.');
    out('  values:');
    operands.forEach((Operand o) =>  out('    ${OperandType.asString(o.type)}: ${o.value.toRadixString(16)}'));
    
    return operands;
  }
}
