pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// KingBar is the coolest bar in town. You come in with some King, and leave with more! The longer you stay, the more King you get.
//
// This contract handles swapping to and from xKing, KingSwap's staking token.
contract KingBar is ERC20("KingBar", "xSUSHI"){
    using SafeMath for uint256;
    IERC20 public king;

    // Define the King token contract
    constructor(IERC20 _king) public {
        king = _king;
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks King and mints xKing
    function enter(uint256 _amount) public {
        // Gets the amount of King locked in the contract
        uint256 totalKing = king.balanceOf(address(this));
        // Gets the amount of xKing in existence
        uint256 totalShares = totalSupply();
        // If no xKing exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalKing == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xKing the King is worth. The ratio will change overtime, as xKing is burned/minted and King deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalKing);
            _mint(msg.sender, what);
        }
        // Lock the King in the contract
        king.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unclocks the staked + gained King and burns xKing
    function leave(uint256 _share) public {
        // Gets the amount of xKing in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of King the xKing is worth
        uint256 what = _share.mul(king.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        king.transfer(msg.sender, what);
    }
}
