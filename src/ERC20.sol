// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC20.sol";

contract ERC20 is IERC20Metadata {
    mapping(address => uint256) private _balances;
    address _owner;
    string _name;
    string _symbol;
    uint256 _totalSupply;
    uint8 _decimals = 18;
    mapping(address => mapping(address => uint256)) _approvals;

    constructor(string memory newName, string memory newSymbol) {
        _owner = msg.sender;
        _name = newName;
        _symbol = newSymbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _approvals[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approvals[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(_balances[from] >= amount, "insufficient balance");
        require(
            _approvals[from][msg.sender] >= amount,
            "insufficient allowance"
        );
        _balances[from] -= amount;
        _balances[to] += amount;
        _approvals[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == _owner, "only minter can mint");
        _balances[to] += amount;
        _totalSupply += amount;
    }
}
