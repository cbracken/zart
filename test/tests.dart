library tests;

import 'dart:async';
import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:math';

import 'package:unittest/unittest.dart';
import 'package:zart/zart.dart';

part 'mock_ui_provider.dart';
part 'mock_v3_machine.dart';
part 'instruction_tests.dart';
part 'object_tests.dart';

/*
* IMPORTANT: Run in Checked Mode so Assertions fire.
*/

void main() {
  final s = Platform.pathSeparator;
  var defaultGameFile = 'example${s}games${s}minizork.z3';

  File f = new File(defaultGameFile);

  try{
    Z.load(f.readAsBytesSync());
  } on FileSystemException catch (fe){
    //TODO log then print friendly
    print('$fe');
    exit(1);
  } on Exception catch (e){
    //TODO log then print friendly
    print('$e');
    exit(1);
  }

  final int version = 3;
  final int pcAddr = 0x4f05;
  final Machine machine = new MockV3Machine();

  Debugger.setMachine(machine);
  Z.IOConfig = new MockUIProvider();


  group('16-bit signed conversion and math>', (){
    test('sign conversion', (){
      expect(-1, Machine.toSigned(0xFFFF));
      expect(32767, Machine.toSigned(32767));
      expect(-32768, Machine.toSigned(0x10000-32768));
    });

    test('dart ints to 16-bit signed', (){
      expect(65535, Machine.dartSignedIntTo16BitSigned(-1));
      expect(32769, Machine.dartSignedIntTo16BitSigned(-32767));
      expect(0, Machine.dartSignedIntTo16BitSigned(0));
      expect(42, Machine.dartSignedIntTo16BitSigned(42));

      expect(() => Machine.dartSignedIntTo16BitSigned(-32769),
          throwsA(new isInstanceOf<AssertionError>()));

    });

    test('division', (){
      //ref (2.4.3)
      expect(-5, -11 ~/ 2);
      expect(5, -11 ~/ -2);
      expect(-5, 11 ~/ -2);
      expect(3, 13 % -5);

      int doMod(a, b){

        var result = a.abs() % b.abs();
        if (a < 0) { result = -result;
        }
        return result;
      }


      expect(-3, doMod(-13, -5));
      expect(-3, doMod(-13, 5));
    });

  });

  group('ZSCII Tests>', (){
    test('unicode translations', (){
      for(int i = 155; i <= 223; i++){
        var s = new StringBuffer();
        s.writeCharCode(ZSCII.UNICODE_TRANSLATIONS['$i']);
        expect(s.toString(), ZSCII.ZCharToChar(i));
      }
    });

    test('readZString', (){
      var addrStart = 0x10e7c;
      var addrEnd = 0x10e9a;
      var testString = 'An old leather bag, bulging with coins, is here.';
      expect(testString, ZSCII.readZString(addrStart));

      // address after string end should be at 0xb0be
      expect(addrEnd, Z.machine.callStack.pop());
    });

  });

  group('RNG>', (){
    test('in bounds', (){
      var r = new Random(new DateTime.now().millisecond);

      for(int i = 0; i < 1000; i++){
        var result = r.nextInt(10) + 1;
        expect(result >= 1 && result <= 10, isTrue);
      }

    });

  });


  group('BinaryHelper Tests>', (){
    test('isSet() true', (){
      expect('1111', 0xf.toRadixString(2));
      expect(BinaryHelper.isSet(15, 0), isTrue);
      expect(BinaryHelper.isSet(15, 1), isTrue);
      expect(BinaryHelper.isSet(15, 2), isTrue);
      expect(BinaryHelper.isSet(15, 3), isTrue);
      expect(BinaryHelper.isSet(15, 4), isFalse);
      expect(BinaryHelper.isSet(15, 5), isFalse);
      expect(BinaryHelper.isSet(15, 6), isFalse);
      expect(BinaryHelper.isSet(15, 7), isFalse);

      expect('11110000', 0xf0.toRadixString(2));
      expect(BinaryHelper.isSet(240, 0), isFalse);
      expect(BinaryHelper.isSet(240, 1), isFalse);
      expect(BinaryHelper.isSet(240, 2), isFalse);
      expect(BinaryHelper.isSet(240, 3), isFalse);
      expect(BinaryHelper.isSet(240, 4), isTrue);
      expect(BinaryHelper.isSet(240, 5), isTrue);
      expect(BinaryHelper.isSet(240, 6), isTrue);
      expect(BinaryHelper.isSet(240, 7), isTrue);
    });

    test('bottomBits()', (){
      expect(24, BinaryHelper.bottomBits(88, 6));
    });

    test('setBit()', (){
      expect(1, BinaryHelper.set(0, 0));
      expect(pow(2, 8), BinaryHelper.set(0, 8));
      expect(pow(2, 16), BinaryHelper.set(0, 16));
      expect(pow(2, 32), BinaryHelper.set(0, 32));
    });

    test('unsetBit()', (){
      expect(0xFE, BinaryHelper.unset(0xFF, 0));
      expect(0xFD, BinaryHelper.unset(0xFF, 1));
      expect(0, BinaryHelper.unset(pow(2, 8), 8));
      expect(0, BinaryHelper.unset(pow(2, 16), 16));
      expect(0, BinaryHelper.unset(pow(2, 32), 32));
    });
  });

  group('memory tests> ', (){
    test('read byte', (){
      expect(version, Z.machine.mem.loadb(0x00));
    });

    test('read word', (){
      expect(pcAddr, Z.machine.mem.loadw(Header.PC_INITIAL_VALUE_ADDR));
    });

    test('write byte', (){
      Z.machine.mem.storeb(0x00, 42);

      expect(42, Z.machine.mem.loadb(0x00));

      Z.machine.mem.storeb(0x00, version);

      expect(version, Z.machine.mem.loadb(0x00));
    });

    test('write word', (){
      Z.machine.mem.storew(Header.PC_INITIAL_VALUE_ADDR, 42420);

      expect(42420, Z.machine.mem.loadw(Header.PC_INITIAL_VALUE_ADDR));

      Z.machine.mem.storew(Header.PC_INITIAL_VALUE_ADDR, pcAddr);

      expect(pcAddr, Z.machine.mem.loadw(Header.PC_INITIAL_VALUE_ADDR));
    });

    test('read global var', (){
      expect(11803, Z.machine.mem.loadw(Z.machine.mem.globalVarsAddress + 8)); // offset

      expect(11803, Z.machine.mem.readGlobal(0x14)); // from global
    });

    test('write global var', (){
      Z.machine.mem.writeGlobal(0x14, 41410);

      expect(41410, Z.machine.mem.readGlobal(0x14));

      Z.machine.mem.writeGlobal(0x14, 8101);

      expect(8101, Z.machine.mem.readGlobal(0x14));
    });
  });

  objectTests();

  instructionTests();

}
