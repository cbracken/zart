part of tests;


void objectTests(){
  group('Objects>', (){
    test('remove', (){

      var o1 = new GameObject(1); //forest

      // check if we have the right object and
      // assumptions are correct.
      expect('pair of hands', o1.shortName);
      expect(247, o1.parent);
      expect(2, o1.sibling);
      expect(0, o1.child);
      expect(o1.isFlagBitSet(14), isTrue);
      expect(o1.isFlagBitSet(28), isTrue);

      var ls = o1.leftSibling(); //248
      var p = new GameObject(36);

      o1.removeFromTree();
      //check that 2 is now the sibling of o1's
      //left sibling
      expect(2, new GameObject(ls).sibling);

      expect(0, o1.parent);
      expect(0, o1.sibling);
    });

    test('insert', (){
      var o1 = new GameObject(1); //forest
      var p = new GameObject(36); //parent
      var oc = p.child;

      o1.insertTo(36);
      expect(36, o1.parent);

      expect(1, p.child);
      expect(oc, o1.sibling);
    });

    test('get next property', (){
      GameObject o1 = new GameObject(5); //"you";

      expect('you', o1.shortName);

      expect(17, o1.getNextProperty(18));
      expect(0, o1.getNextProperty(17));
      expect(18, o1.getNextProperty(0));

      expect(() => o1.getNextProperty(19),
        throwsA(new isInstanceOf<GameException>()));

    });

    test('get property', (){
      GameObject o1 = new GameObject(5); //"you";

      expect('you', o1.shortName);

      expect(0x295c, o1.getPropertyValue(17));

      //throw on property len > 2
      expect(() => o1.getPropertyValue(18),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('set property', (){
      GameObject o1 = new GameObject(31); //"frigid river";

      expect('Frigid River', o1.shortName);

      o1.setPropertyValue(30, 0xffff);
      //should truncate to 0xff since prop #30 is len 1
      expect(0xff, o1.getPropertyValue(30));

      o1.setPropertyValue(30, 0x13);
      expect(0x13, o1.getPropertyValue(30));

      expect(0x951a, o1.getPropertyValue(23));

      o1.setPropertyValue(11, 0xfff);
      expect(0xfff, o1.getPropertyValue(11));

      expect(0xee83, o1.getPropertyValue(5));

      //throw on prop no exist
      expect(() => o1.setPropertyValue(13, 0xffff),
          throwsA(new isInstanceOf<GameException>()));

      o1 = new GameObject(29);

      //throw on prop len > 2
      expect(() => o1.setPropertyValue(29, 0xffff),
          throwsA(new isInstanceOf<GameException>()));

    });

    test('attributes are set', (){
      GameObject o1 = new GameObject(4);// "cretin";

      expect('cretin', o1.shortName);

      expect(o1.isFlagBitSet(7), isTrue);
      expect(o1.isFlagBitSet(9), isTrue);
      expect(o1.isFlagBitSet(14), isTrue);
      expect(o1.isFlagBitSet(30), isTrue);

      //check some that aren't set:
      expect(o1.isFlagBitSet(1), isFalse);
      expect(o1.isFlagBitSet(4), isFalse);
      expect(o1.isFlagBitSet(6), isFalse);
      expect(o1.isFlagBitSet(13), isFalse);
      expect(o1.isFlagBitSet(15), isFalse);
      expect(o1.isFlagBitSet(29), isFalse);
      expect(o1.isFlagBitSet(31), isFalse);
    });

    test ('unset attribute', (){
      GameObject o1 = new GameObject(4);// "cretin";
      expect(o1.isFlagBitSet(7), isTrue);
      o1.unsetFlagBit(7);
      expect(o1.isFlagBitSet(7), isFalse);

      expect(o1.isFlagBitSet(9), isTrue);
      o1.unsetFlagBit(9);
      expect(o1.isFlagBitSet(9), isFalse);

      expect(o1.isFlagBitSet(14), isTrue);
      o1.unsetFlagBit(14);
      expect(o1.isFlagBitSet(14), isFalse);

      o1.setFlagBit(7);
      o1.setFlagBit(9);
      o1.setFlagBit(14);
    });

    test('set attribute', (){
      GameObject o1 = new GameObject(30);// "you";
      expect(o1.isFlagBitSet(1), isFalse);
      o1.setFlagBit(1);
      expect(o1.isFlagBitSet(1), isTrue);

      expect(o1.isFlagBitSet(0), isFalse);
      o1.setFlagBit(0);
      expect(o1.isFlagBitSet(0), isTrue);

      expect(o1.isFlagBitSet(31), isFalse);
      o1.setFlagBit(31);
      expect(o1.isFlagBitSet(31), isTrue);

      o1.unsetFlagBit(1);
      o1.unsetFlagBit(0);
      o1.unsetFlagBit(31);
    });


    test('get property address', (){
      GameObject o1 = new GameObject(180); //"west of house"

      var addr = o1.getPropertyAddress(31);

      expect(0x1c2a, addr);

      var pnum = GameObject.propertyNumber(addr - 1);

      expect(31, pnum);

      var val = o1.getPropertyValue(pnum);

      expect(0x51, val);

      addr = o1.getPropertyAddress(pnum);

      expect(0x1c2a, addr);

      addr = o1.getPropertyAddress(0);
      expect(0, addr);

    });

    test('get property length', (){
      GameObject o1 = new GameObject(232); //"Entrance to Hades"

      expect(4, GameObject.propertyLength(o1.getPropertyAddress(28) - 1));
      expect(1, GameObject.propertyLength(o1.getPropertyAddress(23) - 1));
      expect(4, GameObject.propertyLength(o1.getPropertyAddress(21) - 1));
      expect(2, GameObject.propertyLength(o1.getPropertyAddress(17) - 1));
      expect(1, GameObject.propertyLength(o1.getPropertyAddress(5) - 1));
      expect(8, GameObject.propertyLength(o1.getPropertyAddress(4) - 1));
    });

  });



}
