// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IPoolManager} from "../../../../v4-core/src/interfaces/IPoolManager.sol";
import {IDynamicFeeManager} from "../../../../v4-core/src/interfaces/IDynamicFeeManager.sol";
import {Hooks} from "../../../../v4-core/src/libraries/Hooks.sol";
import {FeeLibrary} from "../../../../v4-core/src/libraries/FeeLibrary.sol";
import {BaseHook} from "../../BaseHook.sol";
import {PoolKey} from "../../../../v4-core/src/types/PoolKey.sol";

contract VolatilityOracle is BaseHook, IDynamicFeeManager {
    using FeeLibrary for uint24;

    error MustUseDynamicFee();

    uint32 deployTimestamp;

    function getFee(
        address,
        PoolKey calldata,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external view returns (uint24) {
        uint24 startingFee = 3000;
        uint32 lapsed = _blockTimestamp() - deployTimestamp;
        return startingFee + (uint24(lapsed) * 100) / 60; // 100 bps a minute
    }

    /// @dev For mocking
    function _blockTimestamp() internal view virtual returns (uint32) {
        return uint32(block.timestamp);
    }

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {
        deployTimestamp = _blockTimestamp();
    }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
                beforeInitialize: true,
                afterInitialize: false,
                beforeModifyPosition: false,
                afterModifyPosition: false,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                noOp: false
            });
    }

    function beforeInitialize(
        address,
        PoolKey calldata key,
        uint160,
        bytes calldata
    ) external pure override returns (bytes4) {
        if (!key.fee.isDynamicFee()) revert MustUseDynamicFee();
        return VolatilityOracle.beforeInitialize.selector;
    }

    function getFee(
        address sender,
        PoolKey calldata key
    ) external view override returns (uint24) {}
}
