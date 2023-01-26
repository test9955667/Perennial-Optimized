pragma solidity ^0.8.0;

import {IProduct} from "@perennial-interfaces/IProduct.sol";
import {UFixed18} from "@equilibria/root/token/types/Token18.sol";

import {Test} from "forge-std/Test.sol";

contract MockMultiInvoker {
      enum PerennialAction {
        NO_OP,
        DEPOSIT,
        WITHDRAW,
        OPEN_TAKE,
        CLOSE_TAKE,
        OPEN_MAKE,
        CLOSE_MAKE,
        CLAIM,
        WRAP,
        UNWRAP,
        WRAP_AND_DEPOSIT,
        WITHDRAW_AND_UNWRAP
    }

    struct Invocation {
        PerennialAction action;
        bytes args;
    }

      function invoke(Invocation[] calldata invocations) external {
        // ACTION TYPES
        // 
        // 0000 0000
        // 

        for (uint256 i = 0; i < invocations.length; i++) {
            Invocation memory invocation = invocations[i];

            // Deposit from `msg.sender` into `account`s `product` collateral account
            if (invocation.action == PerennialAction.DEPOSIT) {
                (address account, IProduct product, UFixed18 amount) = abi.decode(invocation.args, (address, IProduct, UFixed18));
                //depositTo(account, product, amount);

            // Withdraw from `msg.sender`s `product` collateral account to `receiver`
            } else if (invocation.action == PerennialAction.WITHDRAW) {
                (address receiver, IProduct product, UFixed18 amount) = abi.decode(invocation.args, (address, IProduct, UFixed18));
                //collateral.withdrawFrom(msg.sender, receiver, product, amount);

            // Open a take position on behalf of `msg.sender`
            } else if (invocation.action == PerennialAction.OPEN_TAKE) {
                (IProduct product, UFixed18 amount) = abi.decode(invocation.args, (IProduct, UFixed18));
                //product.openTakeFor(msg.sender, amount);

            // Close a take position on behalf of `msg.sender`
            } else if (invocation.action == PerennialAction.CLOSE_TAKE) {
                (IProduct product, UFixed18 amount) = abi.decode(invocation.args, (IProduct, UFixed18));
                //product.closeTakeFor(msg.sender, amount);

            // Open a make position on behalf of `msg.sender`
            } else if (invocation.action == PerennialAction.OPEN_MAKE) {
                (IProduct product, UFixed18 amount) = abi.decode(invocation.args, (IProduct, UFixed18));
               // product.openMakeFor(msg.sender, amount);

            // Close a make position on behalf of `msg.sender`
            } else if (invocation.action == PerennialAction.CLOSE_MAKE) {
                (IProduct product, UFixed18 amount) = abi.decode(invocation.args, (IProduct, UFixed18));
               // product.closeMakeFor(msg.sender, amount);

            // Claim `msg.sender`s incentive reward for `product` programs
            } else if (invocation.action == PerennialAction.CLAIM) {
                (IProduct product, uint256[] memory programIds) = abi.decode(invocation.args, (IProduct, uint256[]));
                //controller.incentivizer().claimFor(msg.sender, product, programIds);

            // Wrap `msg.sender`s USDC into DSU and return the DSU to `account`
            } else if (invocation.action == PerennialAction.WRAP) {
                (address receiver, UFixed18 amount) = abi.decode(invocation.args, (address, UFixed18));
                //wrap(receiver, amount);

            // Unwrap `msg.sender`s DSU into USDC and return the USDC to `account`
            } else if (invocation.action == PerennialAction.UNWRAP) {
                (address receiver, UFixed18 amount) = abi.decode(invocation.args, (address, UFixed18));
                //unwrap(receiver, amount);

            // Wrap `msg.sender`s USDC into DSU and deposit into `account`s `product` collateral account
            } else if (invocation.action == PerennialAction.WRAP_AND_DEPOSIT) {
                (address account, IProduct product, UFixed18 amount) = abi.decode(invocation.args, (address, IProduct, UFixed18));
                //wrapAndDeposit(account, product, amount);
            }

            // Withdraw DSU from `msg.sender`s `product` collateral account, unwrap into USDC, and return the USDC to `receiver`
            else if (invocation.action == PerennialAction.WITHDRAW_AND_UNWRAP) {
                (address receiver, IProduct product, UFixed18 amount) = abi.decode(invocation.args, (address, IProduct, UFixed18));
                //withdrawAndUnwrap(receiver, product, amount);
            }
        }
    }
}