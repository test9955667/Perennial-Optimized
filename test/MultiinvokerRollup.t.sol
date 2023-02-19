pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {MultiInvokerRollup, MockMultiInvoker} from "../src/MultiinvokerRollup.sol";

contract MultiinvokerRollupTest is Test {
    MultiInvokerRollup public invoker;
    event LogBytes(bytes);
    event LogBytes32(bytes32);
    event LogString(string);

    address product = 0x04Fb26775A0E1C4d62CF1ac8AAAe1d0094FC2205;

    constructor() {
        invoker = new MultiInvokerRollup();

    }

    // tests deposit for first time registering user + product in cache and after they are in cache 
    function testCalldataBasic() public {

        bytes memory firstCallPayload = firstCall();

        address(invoker).call(firstCallPayload);

        bytes memory actions = hex'00';
        bytes memory addrLen = hex'01';
        bytes memory addr = hex'01'; // 0th nonce for this user 
        bytes memory productLen = hex'01';
        bytes memory prod = hex'01'; // 0th nonce for this product
        bytes memory amountLen = hex'09';
        bytes memory amountBytes = hex'141CA8C65B95EC0000';

        bytes memory cachedPayload = abi.encodePacked(actions, addrLen, addr, productLen, prod, amountLen, amountBytes);

        address(invoker).call(cachedPayload);
        
    }

    // tests that setting address cache in first time call to invoker 
    function testCacheSet() public {

        bytes memory firstCallPayload = firstCall();

        address(invoker).call(firstCallPayload);

        assertEq(invoker.userNonces((address(this))), 1);
        assertEq(invoker.productNonces(product), 1);

    }

    function testClaimFor() public {
        bytes memory actions = hex'06';
        bytes memory productLen = hex'00'; // adding new whole product to cache
        bytes memory prod = abi.encodePacked(product);
        bytes memory arrayLen = hex'03';
        bytes memory len0 = hex'02';
        bytes memory program0 = hex'5B9E';
        bytes memory len1 = hex'01';
        bytes memory program1 = hex'00';
        bytes memory len2 = hex'01';
        bytes memory program2 = hex'4A';

        bytes memory payload = abi.encodePacked(actions, productLen, prod, arrayLen, len0, program0, len1, program1, len2, program2);

        emit LogBytes(payload);

        address(invoker).call(payload);

    }


    function testMultiAction() public {
        bytes memory firstCallPayload = firstCall();

        address(invoker).call(firstCallPayload);

        
    }

    function firstCall() private returns(bytes memory payload) {

        bytes memory actions = hex'00';
        bytes memory addrLen = hex'00'; // adding new whole address to cache
        bytes memory addr = abi.encodePacked(address(this));
        bytes memory productLen = hex'00'; // adding new whole product to cache
        bytes memory prod = abi.encodePacked(product);
      
        bytes memory amountLen = hex'08'; // 8 bytes 
        bytes memory amountBytes = hex'4563918244f40000';
        

        return abi.encodePacked(actions, addrLen, addr, productLen, prod, amountLen, amountBytes);

    }

}