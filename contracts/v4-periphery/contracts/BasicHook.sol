pragma solidity ^0.8.20;
import {BaseHook} from "./BaseHook.sol";
import {Hooks} from "../../v4-core/src/libraries/Hooks.sol";
import {IHooks} from "../../v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "../../v4-core/src/interfaces/IPoolManager.sol";

contract BasicHook is BaseHook {

    constructor(IPoolManager _poolManager)BaseHook(_poolManager){
         Hooks.validateHookAddress(IHooks(address(this)), getHooksCalls());
    }
    function getHooksCalls()
        public
        pure
        virtual
        override
        returns (Hooks.Calls memory)
    {
        return Hooks.Calls({
                beforeInitialize: false,
                afterInitialize: false,
                beforeModifyPosition: false,
                afterModifyPosition: false,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                noOp: true
            });
    }
}