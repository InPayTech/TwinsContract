pragma solidity ^0.4.8;

import "./Token.sol";

contract TwinsContract is Token {


    function TwinsContract() public {
    }

    function switchToToken(uint256 newToken) public {
      tokenInWork[msg.sender] = newToken;
    }

    function getTokenInWork(address user) public view returns (uint256 token){
      return tokenInWork[user];
    }

    //Phonon functions
    //====================================================
    // NOTE! Correctness of executing these functions cannot be checked from 
    // inside IPVM, it should be checked externally by Phonon system.
    function mintToken(uint256 token, address _to, uint256 _value) public returns (bool success) {
        balances[token][_to] += _value;
        Mint(token, msg.sender, _to, _value);
        return true;
    }

    function dedicatedBurn(uint256 token, address processingMN, uint256 _value) public returns (bool success) {
        require(balances[token][msg.sender] >= _value);
        balances[token][msg.sender] -= _value;
        Burn(token, msg.sender, processingMN, _value);
        return true;
    }

    //Tokens functions
    //====================================================

    function transferToken(uint256 token, address _to, uint256 _value) public returns (bool success) {
        require(balances[token][msg.sender] >= _value);
        require(!(_to==address(0x0)));
        balances[token][msg.sender] -= _value;
        balances[token][_to] += _value;
        TransferToken(token, msg.sender, _to, _value);
        return true;
    }

    function transferTokenFrom(uint256 token, address _from, address _to, uint256 _value) public  returns (bool success) {
        uint256 allowance = allowed[token][_from][msg.sender];
        require(!(_to==address(0x0)));
        require(balances[token][_from] >= _value); //TestRPC randomly fails with invalid opcode here
        require(allowance >= _value);
        balances[token][_to] += _value;
        balances[token][_from] -= _value;
        allowed[token][_from][msg.sender] -= _value;
        TransferToken(token, _from, _to, _value);
        return true;
    }

    function balanceOfToken(uint256 token, address _owner) view public returns (uint256 balance) {
        return balances[token][_owner];
    }

    function approveToken(uint256 token, address _spender, uint256 _value) public returns (bool success) {
        allowed[token][msg.sender][_spender] = _value;
        ApprovalToken(token, msg.sender, _spender, _value);
        return true;
    }

    function allowanceToken(uint256 token, address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[token][_owner][_spender];
    }

    //ERC20 Interface
    //====================================================
    function transfer(address _to, uint256 _value) public returns (bool success) {
        return transferToken(getTokenInWork(msg.sender), _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return transferTokenFrom(getTokenInWork(msg.sender), _from, _to, _value);
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balanceOfToken(getTokenInWork(msg.sender), _owner);
    }

    function approve(address _spender, uint256 _value) public  returns (bool success) {
        return approveToken(getTokenInWork(msg.sender), _spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowanceToken(getTokenInWork(msg.sender), _owner, _spender);
    }

    mapping (address => uint256) tokenInWork;
    mapping (uint256 => mapping (address => uint256)) balances;
    mapping (uint256 => mapping (address => mapping (address => uint256))) allowed;

    event TransferToken(uint256 token, address indexed _from, address indexed _to, uint256 _value);
    event ApprovalToken(uint256 token, address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(uint256 token, address indexed _from, address indexed _to, uint256 _value);
    event Burn(uint256 token, address indexed _from, address indexed prosessingMN, uint256 _value);

}
