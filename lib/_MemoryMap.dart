class _MemoryMap {

  // A word address specifies an even address in the bottom 128K of memory
  // (by giving the address divided by 2). (Word addresses are used only in the abbreviations table.)

  final List<int> _mem; //each element in the array represents a byte of z-machine memory.

  // memory map address offsets
  int abbrAddress;
  int objectsAddress;
  int globalVarsAddress;
  int staticMemAddress;
  int dictionaryAddress;
  int highMemAddress;
  
  _MemoryMap(this._mem);

  void checkMem(){

  }

  // Reads a global variable (word)
  int readGlobal(int which){

   if (which < 0x10 || which > 0xff)
     throw const Exception('Global lookup register out of range.');

   //global 0x00 means pop from stack
   return which == 0 ? Z.pop() : loadw(globalVarsAddress + (which * 2));
  }
  
  // Writes a global variable (word)
  void writeGlobal(int which, int value){
    if (which < 0x10 || which > 0xff)
      throw const Exception('Global lookup register out of range.');
    
    if (which == 0){
      //global 0x00 means push to stack
      Z.push(value);
    }else{
      storew(globalVarsAddress + (which * 2), value);
    }
  }
  
  //static and dynamic memory (1.1.1, 1.1.2)
  //get byte
  int loadb(int address){
    checkBounds(address);
    return _mem[address];
  }

  //get word
  int loadw(int address){
    checkBounds(address);
    checkBounds(address + 1);
    return _getWord(address);
  }

  //dynamic memory only (1.1.1)
  //put byte
  void storeb(int address, int value){
    checkBounds(address);
    //TODO validate
    
    if (value > 0xff) throw const Exception('byte out of range.');
    
    _mem[address] = value;
  }

  //put word
  void storew(int address, int value){
    checkBounds(address);
    checkBounds(address + 1);
    
    if (value > 0xffff)
      throw const Exception('word out of range');

    _mem[address] = value >> 8;
    _mem[address + 1] = value & 0xff;
  }

  int _getWord(int address) => (_mem[address] << 8) | _mem[address + 1];

  void checkBounds(int address){
   if (address == null || address < 0 || address > _mem.length - 1){
     throw const Exception('Attempted access to memory address'
       ' that is out of bounds.');
   }
  }

  List getRange(int address, int howMany){
    checkBounds(address);
    checkBounds(address + howMany);
    return _mem.getRange(address, howMany);
  }

  int get size() => _mem.length;

}


//enumerates addressTypes
class AddressType{
  final String _str;

  const AddressType(this._str);

  static final ByteAddress = const AddressType('ByteAddress');
  static final WordAddress = const AddressType('WordAddress');
  static final PackedAddress = const AddressType('PackedAddress');
}