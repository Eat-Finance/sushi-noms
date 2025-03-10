// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/// @dev brief interface for entering SUSHI bar (xSUSHI).
interface ISushiBarEnter { 
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function enter(uint256 amount) external;
}

/// @dev brief interface for depositing into AAVE lending pool.
interface IAaveDeposit {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}

/// @dev contract that batches SUSHI staking into AAVE xSUSHI (aXSUSHI).
contract Saave {
    ISushiBarEnter constant sushiToken = ISushiBarEnter(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2); // SUSHI token contract
    ISushiBarEnter constant sushiBar = ISushiBarEnter(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272); // xSUSHI staking contract for SUSHI
    IAaveDeposit constant aave = IAaveDeposit(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9); // AAVE lending pool contract for xSUSHI staking into aXSUSHI
    
    constructor() public {
        sushiToken.approve(address(sushiBar), type(uint256).max); // max approve `sushiBar` spender to stake SUSHI into xSUSHI from this contract
        sushiBar.approve(address(aave), type(uint256).max); // max approve `aave` spender to stake xSUSHI into aXSUSHI from this contract
    }
    
    /// @dev stake `amount` SUSHI into aXSUSHI by batching calls to `sushiBar` and `aave` lending pool.
    function saave(uint256 amount) external {
        sushiToken.transferFrom(msg.sender, address(this), amount); // deposit caller SUSHI `amount` into this contract
        sushiBar.enter(amount); // stake deposited SUSHI `amount` into xSUSHI
        aave.deposit(address(sushiBar), sushiBar.balanceOf(address(this)), msg.sender, 0); // stake resulting xSUSHI into aXSUSHI - send to caller
    }
    
    /// @dev stake `amount` SUSHI into aXSUSHI for benefit of `to` by batching calls to `sushiBar` and `aave` lending pool.
    function saaveTo(address to, uint256 amount) external {
        sushiToken.transferFrom(msg.sender, address(this), amount); // deposit caller SUSHI `amount` into this contract
        sushiBar.enter(amount); // stake deposited SUSHI `amount` into xSUSHI
        aave.deposit(address(sushiBar), sushiBar.balanceOf(address(this)), to, 0); // stake resulting xSUSHI into aXSUSHI - send to `to`
    }
}
