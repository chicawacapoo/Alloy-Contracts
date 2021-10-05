// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./libs/GambleBase.sol";
import "./libs/IBEP20.sol";
import "./libs/SafeBEP20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

contract Wheel is GambleBase, Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using SafeERC20 for IERC20;

    IBEP20 public token;

    uint256[52] public wheel = [50,0,3,0,5,1,3,0,10,3,1,5,1,20,1,3,0,3,1,5,0,10,1,3,5,1,0,1,3,0,5,1,3,0,10,5,1,3,1,20,1,3,1,5,0,3,0,5,0,10,3,1];

    mapping(address => BetResult) public lastResult;

    struct BetResult {
        uint256 spin;
        uint256 multiplier;
        uint256 reward;
    }

    constructor(IBEP20 _token) public {
        token = _token;
    }

    function _spin() internal view returns (uint256) {
        return rand().mul(52).div(1000);
    }

    event Result(address indexed account, uint256 spin, uint256 multiplier, uint256 reward);

    function bet(uint256 _1, uint256 _3, uint256 _5, uint256 _10, uint256 _20, uint256 _50) public noContract {
        require(_1 >= 0, 'no negative bets');
        require(_3 >= 0, 'no negative bets');
        require(_5 >= 0, 'no negative bets');
        require(_10 >= 0, 'no negative bets');
        require(_20 >= 0, 'no negative bets');
        require(_50 >= 0, 'no negative bets');

        uint256 spin; uint256 multiplier; uint256 reward;
        // Pull Funds
        uint256 betTotal = _1+_3+_5+_10+_20+_50;
        token.safeTransferFrom(msg.sender, address(this), betTotal);

        // Spin it!
        spin = _spin();
        multiplier = wheel[spin];
        
        if (multiplier > 0) {
            uint256 winningBet;
            
            if (multiplier == 1) {
                winningBet = _1;
            }

            if (multiplier == 3) {
                winningBet = _3;
            }

            if (multiplier == 5) {
                winningBet = _5;
            }

            if (multiplier == 10) {
                winningBet = _10;
            }

            if (multiplier == 20) {
                winningBet = _20;
            }

            if (multiplier == 50) {
                winningBet = _50;
            }

            reward = winningBet.mul(multiplier.add(1));
        }

        if (betTotal > reward) {
            uint256 burnAmount = betTotal.sub(reward).mul(20).div(100);
            token.safeTransfer(0x000000000000000000000000000000000000dEaD, burnAmount);
        }
        
         if (betTotal > reward) {
            uint256 devAmount = betTotal.sub(reward).mul(10).div(100);
            token.safeTransfer(0x39B5Ef29332AFC37D618efE918A7e13c38358f94, devAmount);
        }
        
        token.safeTransfer(msg.sender, reward);

        lastResult[msg.sender] = BetResult({
            spin: spin,
            multiplier: multiplier,
            reward: reward
        });
        emit Result(msg.sender, spin, multiplier, reward);
    }
    
    function transferToken(IERC20 token, address to, uint256 amount) public onlyOwner {
        token.safeTransfer(to, amount);
    }
}