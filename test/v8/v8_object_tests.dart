part of v8_tests;


void objectTestsV8(){
  group('Objects>', (){

    final SHIP = 63;
    final DREAMBRIDGE = 60;
    final PIRATES = 62;
    final LADDER = 64;

    test('remove', (){

      var o1 = new GameObject(SHIP);

      // check if we have the right object and
      // assumptions are correct.
      expect('ship', o1.shortName);
      expect(DREAMBRIDGE, o1.parent);
      expect(LADDER, o1.sibling);
      expect(0, o1.child);

      var ls = o1.leftSibling(); //PIRATES
      var p = new GameObject(DREAMBRIDGE); //(dream bridge)

      o1.removeFromTree();
      //check that 2 is now the sibling of o1's
      //left sibling
      expect(LADDER, new GameObject(ls).sibling);

      expect(0, o1.parent);
      expect(0, o1.sibling);
    });

    test('insert', (){
      var o1 = new GameObject(SHIP); //ship
      var p = new GameObject(DREAMBRIDGE); //parent
      var oc = p.child;

      o1.insertTo(p.id);
      expect(p.id, o1.parent);

      expect(SHIP, p.child);
      expect(oc, o1.sibling);
    });

    test('get property length', (){
      GameObject o1 = new GameObject(SHIP); //ship

      expect(2, GameObject.propertyLength(o1.getPropertyAddress(35) - 1));
      expect(2, GameObject.propertyLength(o1.getPropertyAddress(4) - 1));
      expect(2, GameObject.propertyLength(o1.getPropertyAddress(3) - 1));
      expect(20, GameObject.propertyLength(o1.getPropertyAddress(1) - 1));
    });

    test('get property', (){
      GameObject o1 = new GameObject(SHIP);

      expect('ship', o1.shortName);

      expect(0x3843, o1.getPropertyValue(4));
      expect(0x74a9, o1.getPropertyValue(3));

      //throw on property len > 2
      expect(() => o1.getPropertyValue(1),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('get property address', (){
      GameObject o1 = new GameObject(SHIP); //"west of house"

      var addr = o1.getPropertyAddress(4);

      expect(0x2b41, addr);

      var pnum = GameObject.propertyNumber(addr - 1);

      expect(4, pnum);

      var val = o1.getPropertyValue(pnum);

      expect(0x3843, val);

      addr = o1.getPropertyAddress(pnum);

      expect(0x2b41, addr);

      addr = o1.getPropertyAddress(0);
      expect(0, addr);

    });


    test('get next property', (){
      GameObject o1 = new GameObject(SHIP);

      expect('ship', o1.shortName);

      expect(4, o1.getNextProperty(35));
      expect(3, o1.getNextProperty(4));
      expect(1, o1.getNextProperty(3));
      expect(35, o1.getNextProperty(0));

      expect(() => o1.getNextProperty(19),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('set property', (){
      GameObject o1 = new GameObject(SHIP);

      expect('ship', o1.shortName);

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
      GameObject o1 = new GameObject(SHIP);

      expect('ship', o1.shortName);

      expect(o1.isFlagBitSet(17), isTrue);
      expect(o1.isFlagBitSet(19), isTrue);

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
      GameObject o1 = new GameObject(SHIP);

      expect(o1.isFlagBitSet(17), isTrue);
      o1.unsetFlagBit(17);
      expect(o1.isFlagBitSet(17), isFalse);

      expect(o1.isFlagBitSet(19), isTrue);
      o1.unsetFlagBit(19);
      expect(o1.isFlagBitSet(19), isFalse);

      o1.setFlagBit(19);
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