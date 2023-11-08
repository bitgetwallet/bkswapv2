// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IWombatRouter {
    function getAmountOut(
        address[] calldata _tokenPath,
        address[] calldata _poolPath,
        int256 _amountIn
    ) external view returns (uint256 amountOut, uint256[] memory haircuts);

    function swapExactTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external returns(uint256 amountOut);
}
