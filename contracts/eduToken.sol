/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NOPEEdu_Token is ERC20 {
    constructor() ERC20("EduToken", "WCS") {
        _mint(msg.sender, 1000000000000000000000000); // 1M
    }
}
