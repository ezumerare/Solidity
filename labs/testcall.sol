// SPDX-License-Identifier: MIT
pragma solidity <=0.8.30;

contract A {

    struct hi {

        uint[1] itemOne;
        uint[2] itemTwo;
        uint[3] itemThree;

    }

    function hey(hi memory num) external pure returns(bytes memory) {
        return msg.data; // return bytecode

        /* return -
        
        * 0xaaafa879 - selector function "hey"
        * 000000000000000000000000000000000000000000000000000000000000000
        * 1000000000000000000000000000000000000000000000000000000000000000 - "1" - its uint[1];
        * 20000000000000000000000000000000 - "2" - its uint[2];
        * 000000000000000000000000000000003 - "3" - its uint[3];
        */
    }
}
