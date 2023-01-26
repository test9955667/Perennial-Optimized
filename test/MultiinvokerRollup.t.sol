pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {MultiInvokerRollup, MockMultiInvoker} from "../src/MultiinvokerRollup.sol";

contract MultiinvokerRollupTest is Test {
    MultiInvokerRollup public invoker;
    event LogBytes(bytes);
    event LogString(string);

    constructor() {
        invoker = new MultiInvokerRollup();

    }

    function testCalldata() public {

        address product = 0x04Fb26775A0E1C4d62CF1ac8AAAe1d0094FC2205;
        uint256 amount = 5 ether;

        MockMultiInvoker.Invocation[] memory invocations = new MockMultiInvoker.Invocation[](1);
        invocations[0] = MockMultiInvoker.Invocation({action: MockMultiInvoker.PerennialAction.DEPOSIT, args: abi.encode(address(this), product, amount)});
        
        invoker.invoke(invocations);
      
        bytes memory unoptimizedPayload = abi.encode(hex'f7978936', product, address(this), amount);
        emit LogString("unoptimized payload");
        emit LogBytes(unoptimizedPayload);


        bytes memory actions = hex'00';
        bytes memory addrLen = hex'00'; // adding new whole address to cache
        bytes memory addr = abi.encodePacked(address(this));
        bytes memory productLen = hex'00'; // adding new whole product to cache
        bytes memory prod = abi.encodePacked(product);
      
        bytes memory amountLen = hex'13'; // 19 decimal
        bytes memory amountBytes = hex'4563918244f40000';



        bytes memory payload = abi.encodePacked(actions, addrLen, addr, productLen, prod, amountLen, amountBytes);

        emit LogString("optimized payload no cache");
        emit LogBytes(payload);

        bytes memory cachedPayload = abi.encodePacked(actions, hex'01', hex'01', hex'01', hex'01', amountLen, amountBytes);
        
        emit LogString("optimized payload with cache");
        emit LogBytes(cachedPayload);
    }


}