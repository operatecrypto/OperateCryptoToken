// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.1/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.1/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts@5.0.1/access/Ownable.sol";

/// @custom:security-contact operatecrypto@gmail.com
contract OperateCrypto is ERC20, ERC20Permit, Ownable {
    uint256 public salesTaxRate; 
    address public taxCollector; 

    constructor(address initialOwner)
        ERC20("OperateCrypto", "Operate")
        ERC20Permit("OperateCrypto")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 250000000000 * 10 ** decimals());
        salesTaxRate=50; //0.5% tax
        taxCollector =0x91a8eBb78129dcA2e9bCF998645F3cE99B033352;
    }
    function setSalesTaxRate(uint256 newRate)  external onlyOwner 
    { 
        salesTaxRate = newRate; 
    }
    function setTaxCollector(address newCollector) external onlyOwner 
    {
        taxCollector = newCollector; 
    }
    //function transferFrom( address sender, address recipient, uint256 amount ) override (bool) 
    function transferFrom(address from, address to, uint256 value) public override returns (bool){ 
        if (_isTaxApplicable(from, to)) 
        { 
            uint256 taxAmount = (value * salesTaxRate) / 10000; 
            uint256 afterTaxAmount = value - taxAmount; 
            super.transferFrom(from, taxCollector, taxAmount); 
            return super.transferFrom(from, to, afterTaxAmount); 
        } 
        else 
        { 
            return super.transferFrom(from, to, value); 
        } 
    }
    function _isTaxApplicable(address from, address to) view private returns (bool){
        if(salesTaxRate == 0) return false;
        if(from == taxCollector) return false;
        if(to == taxCollector) return false;
        
        if(from == this.owner()) return false;
        if(to == this.owner()) return false;
        return true;
    }
}
