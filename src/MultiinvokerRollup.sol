pragma solidity ^0.8.0;

import "@multiinvoker/Multiinvoker.sol";
import "./mocks/MockInvoker.sol";

/// @notice JUST A SCRATCHPAD, DO NOT READ
contract MultiInvokerRollup is MockMultiInvoker /**MultiInvoker*/ {
    using UFixed18Lib for uint256;

    event UserAddedToCache(address indexed user, uint256 nonce);
    event ProductAddedToCache(address indexed product, uint256 nonce);

    uint256 public userNonce;
    mapping(uint => address) public userCache;
    mapping(address => uint) public userNonces;

    uint256 public productNonce;
    mapping(uint => address) public productCache;
    mapping(address => uint) public productNonces; 
    

  

    /// @dev fallback eliminates the need to include function sig
    fallback (bytes calldata input) external returns (bytes memory) {
        decodeFallbackAndInvoke(input);
    }

    /// @dev this function serves (@todo will serve*) exactly the same as invoke(Invocation[] memory invocations),
    /// but includes all the logic to handle the highly packed calldata
    function decodeFallbackAndInvoke(bytes calldata input) private {
        uint ptr;
        uint len = input.length;

        for(ptr; ptr < len;) {
            uint action = bytesToUint(input[ptr:ptr+1]);
            
            // solidity doesn't like evaluating bytes as enums :/ 
            // PerennialAction.Deposit 
            if(action == 0) { // DEPOSIT
                address account; IProduct product; UFixed18 amount;
                // decode calldata for first action and shift pointer for next action
                (account, product, amount, ptr) = decodeAddressProductAmount(input, ptr);

                //depositTo(address, IProduct(product), amount);
            } else if (action == 1) { // WITHDRAW
                address receiver; IProduct product; UFixed18 amount;

                (receiver, product, amount, ptr) = decodeAddressProductAmount(input, ptr);

                //withdrawFrom(receiver, product, amount);
            } else if (action == 2) { // OPEN_TAKE
                IProduct product; UFixed18 amount;
                (product, amount, ptr) = decodeProductAmount(input, ptr);

                //product.openTakeFor(msg.sender, amount);  
            } else if (action == 3) { // CLOSE_TAKE
                IProduct product; UFixed18 amount;
                (product, amount, ptr) = decodeProductAmount(input, ptr);

                //product.closeTakeFor(msg.sender, amount);
            } else if (action == 4) { // OPEN_MAKE 
                IProduct product; UFixed18 amount;
                (product, amount, ptr) = decodeProductAmount(input, ptr);

                //product.openMakeFor(msg.sender, amount);
            } else if (action == 5) { // CLOSE_MAKE
                IProduct product; UFixed18 amount;
                (product, amount, ptr) = decodeProductAmount(input, ptr);

            } else if (action == 6) { // CLAIM 

            } else if (action == 7) { // WRAP 

            } else if (action == 8) { // UNWRAP

            } else if (action == 9) { // WRAP_AND_DEPOSIT

            } else if (action == 10) { // WITHDRAW_AND_UNWRAP

            }
            
    
        }
    }

    /// Example Calldata Structure
    /// let ptr
    /// [ptr(userLen), ptr+1:userLen(user registry # OR 20 byte address if userLen == 0)] => address user 
    /// ptr += (userLen OR 20) + 1
    /// [ptr(prodcutLen), ptr+1:productLen(product registry # OR 20 byte address if prdoctLen == 0)] => address product
    /// ptr += (prodcutLen OR 20) + 1
    /// [ptr(amountLen), ptr:amountLen] => uint256 amount 

    function decodeAddressProductAmount(bytes calldata input, uint ptr) private returns (address user, IProduct product, UFixed18 amount, uint) {
        (user, ptr) = decodeUser(input, ptr);
        (product, ptr) = decodeProduct(input, ptr);
        (amount, ptr) = decodeAmount(input, ptr);

        return (user, product, amount, ptr);
    }

    function decodeProductAmount(bytes calldata input, uint ptr) private returns (IProduct product, UFixed18 amount, uint) {
        (product, ptr) = decodeProduct(input, ptr);
        (amount, ptr) = decodeAmount(input, ptr);

        return(product, amount, ptr);
    }

    function decodeAmount(bytes calldata input, uint ptr) private returns (UFixed18 result, uint) {
        
        uint len = bytesToUint(input[ptr:1]);

        bytes memory encodedUint = input[ptr+1:len];

        result = UFixed18Lib.from(bytesToUint(encodedUint));

        ptr += len + 1;

        return (result, ptr);
    }

    /// ADDRESS CACHE FUNCTIONS 

    function decodeUintArray(bytes calldata input, uint ptr) private returns (UFixed18[] memory, uint) {
        // first byte is number of elements in uint array
        uint arrayLen = bytesToUint(input[ptr:ptr+1]);
        UFixed18[] memory result = new UFixed18[](arrayLen);
        uint count = 0;

        for(;count < arrayLen;) {
            ++ptr;
            UFixed18 currUint;

            (currUint, ptr) = decodeAmount(input, ptr);
            
            result[count] = currUint;

            ++count;
        }

        return (result, ptr);
    }



    function decodeUser(bytes calldata input, uint ptr) private returns(address userAddress, uint) {
        uint userLen = bytesToUint(input[ptr:ptr+1]);
        ptr += 1;

        // user is new to registry, add next 20 bytes as address to registry and return address
        if(userLen == 0) {
            userAddress = bytesToAddress(input[ptr:ptr+19]);
            ptr += 19;

            setUserCache(userAddress);

        } else {
            uint256 userNonceLookup = bytesToUint(input[ptr:ptr+userLen]);
            ptr += userLen;
            getUserCacheSafe(userNonceLookup);

        }

        return (userAddress, ptr);
    }

    function decodeProduct(bytes calldata input, uint ptr) private returns(IProduct product, uint) {
        uint productLen = bytesToUint(input[ptr:ptr+1]);
        ptr += 1;

        // user is new to registry, add next 20 bytes as address to registry and return address
        if(productLen == 0) {
            product = IProduct(bytesToAddress(input[ptr:ptr+19]));
            ptr += 19;

            setUserCache(address(product));
            
        } else {
            uint256 productNonceLookup = bytesToUint(input[ptr:ptr+productLen]);
            ptr += productLen;
            getProductCacheSafe(productNonceLookup);

        }

        return (product, ptr);
    }

    function setUserCache(address user) private {
        userCache[userNonce] = user;
        userNonces[user] = userNonce;
        emit UserAddedToCache(user, userNonce);
        ++userNonce;
    }

    function getUserCacheSafe(uint nonce) public returns (address user){
        user = userCache[nonce];
        if(user == address(0x0)) revert("Bad calldata, user not cache");
    }

    function setProductCache(address product) private {
        productCache[productNonce] = product;
        productNonces[product] = productNonce;

        emit ProductAddedToCache(product, productNonce);
        ++productNonce;
    }

    function getProductCacheSafe(uint nonce) public view returns(address product) {
        product = productCache[nonce];
        if(product == address(0x0)) revert("Bad calldata, product not found");
    }

    function bytesToAddress(bytes memory input) private pure returns (address addr) {
        assembly {
            addr := mload(add(input,20))
        } 
    }

    function bytesToUint(bytes memory input) private pure returns (uint res) {
        res = uint(bytes32(input));
    }
}