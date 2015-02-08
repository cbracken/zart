//V5 Object Tests

part of v5_tests;

void objectTestsV5(){
  group('Objects>', (){
    test('remove', (){

      var o1 = new GameObject(18); //golden fish

      // check if we have the right object and
      // assumptions are correct.
      expect('*GOLDEN FISH*', o1.shortName);
      expect(16, o1.parent);
      expect(19, o1.sibling);
      expect(0, o1.child);

      var ls = o1.leftSibling(); //19
      var p = new GameObject(16); //lakeside

      o1.removeFromTree();
      //check that 2 is now the sibling of o1's
      //left sibling
      expect(19, new GameObject(ls).sibling);

      expect(0, o1.parent);
      expect(0, o1.sibling);
    });

    test('insert', (){
      var o1 = new GameObject(18); //golden fish
      var p = new GameObject(16); //lakeside
      var oc = p.child;

      o1.insertTo(p.id);
      expect(p.id, o1.parent);

      expect(18, p.child);
      expect(oc, o1.sibling);
    });

    test('get property length', (){
      GameObject o1 = new GameObject(18); //"golden fish"

      expect(2, GameObject.propertyLength(o1.getPropertyAddress(27) - 1));
      expect(2, GameObject.propertyLength(o1.getPropertyAddress(4) - 1));
      expect(2, GameObject.propertyLength(o1.getPropertyAddress(2) - 1));
      expect(6, GameObject.propertyLength(o1.getPropertyAddress(1) - 1));
    });

    test('get property', (){
      GameObject o1 = new GameObject(18); //"golden fish";      expect('*GOLDEN FISH*', o1.shortName);

      expect(0x22da, o1.getPropertyValue(4));
      expect(0x0007, o1.getPropertyValue(2));

      //throw on property len > 2
      expect(() => o1.getPropertyValue(1),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('get property address', (){
      GameObject o1 = new GameObject(18); //"west of house"

      var addr = o1.getPropertyAddress(4);

      expect(0x868, addr);

      var pnum = GameObject.propertyNumber(addr - 1);

      expect(4, pnum);

      var val = o1.getPropertyValue(pnum);

      expect(0x22da, val);

      addr = o1.getPropertyAddress(pnum);

      expect(0x868, addr);

      addr = o1.getPropertyAddress(0);
      expect(0, addr);

    });


    test('get next property', (){
      GameObject o1 = new GameObject(18); //"golden fish";

      expect('*GOLDEN FISH*', o1.shortName);

      expect(4, o1.getNextProperty(27));
      expect(2, o1.getNextProperty(4));
      expect(1, o1.getNextProperty(2));
      expect(27, o1.getNextProperty(0));

      expect(() => o1.getNextProperty(19),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('set property', (){
      GameObject o1 = new GameObject(18); //"golden fish";

      expect('*GOLDEN FISH*', o1.shortName);

      o1.setPropertyValue(4, 0xffff);
      //should truncate to 0xff since prop #30 is len 1
      expect(0xffff, o1.getPropertyValue(4));

      //throw on prop no exist
      expect(() => o1.setPropertyValue(13, 0xffff),
          throwsA(new isInstanceOf<GameException>()));

      //throw on prop len > 2
      expect(() => o1.setPropertyValue(1, 0xffff),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('attributes are set', (){
      GameObject o1 = new GameObject(58);// "the door";

      expect('the door', o1.shortName);

      expect(o1.isFlagBitSet(6), isTrue);
      expect(o1.isFlagBitSet(12), isTrue);
      expect(o1.isFlagBitSet(13), isTrue);
      expect(o1.isFlagBitSet(17), isTrue);
      expect(o1.isFlagBitSet(21), isTrue);

      //check some that aren't set:
      expect(o1.isFlagBitSet(1), isFalse);
      expect(o1.isFlagBitSet(5), isFalse);
      expect(o1.isFlagBitSet(7), isFalse);
      expect(o1.isFlagBitSet(11), isFalse);
      expect(o1.isFlagBitSet(14), isFalse);
      expect(o1.isFlagBitSet(16), isFalse);
      expect(o1.isFlagBitSet(18), isFalse);
      expect(o1.isFlagBitSet(40), isFalse);
    });

    test ('unset attribute', (){
      GameObject o1 = new GameObject(58);// "the door";
      expect(o1.isFlagBitSet(6), isTrue);
      o1.unsetFlagBit(6);
      expect(o1.isFlagBitSet(6), isFalse);

      expect(o1.isFlagBitSet(12), isTrue);
      o1.unsetFlagBit(12);
      expect(o1.isFlagBitSet(12), isFalse);

      expect(o1.isFlagBitSet(17), isTrue);
      o1.unsetFlagBit(17);
      expect(o1.isFlagBitSet(17), isFalse);

      o1.setFlagBit(6);
      o1.setFlagBit(12);
      o1.setFlagBit(17);
    });

    test('set attribute', (){
      GameObject o1 = new GameObject(58);// "the door";
      expect(o1.isFlagBitSet(1), isFalse);
      o1.setFlagBit(1);
      expect(o1.isFlagBitSet(1), isTrue);

      expect(o1.isFlagBitSet(0), isFalse);
      o1.setFlagBit(0);
      expect(o1.isFlagBitSet(0), isTrue);

      expect(o1.isFlagBitSet(47), isFalse);
      o1.setFlagBit(47);
      expect(o1.isFlagBitSet(47), isTrue);

      o1.unsetFlagBit(1);
      o1.unsetFlagBit(0);
      o1.unsetFlagBit(47);
    });
  });
}