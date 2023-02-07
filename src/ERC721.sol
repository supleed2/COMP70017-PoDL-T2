// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./libraries/StringUtils.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC721.sol";

contract ERC721 is IERC721Metadata {
    mapping(uint256 => address) _approvals;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => bool)) _fullApprovals;
    mapping(uint256 => address) _owners;
    address _contractOwner;
    string _name;
    string _symbol;
    string _baseUri;
    IERC20 public _paymentToken;
    uint256 _tokenPrice;
    uint256 _totalSupply;

    constructor(
        string memory newName,
        string memory newSymbol,
        string memory newBaseUri,
        IERC20 newPaymentToken,
        uint256 newInitialTokenPrice
    ) {
        _contractOwner = msg.sender;
        _name = newName;
        _symbol = newSymbol;
        _baseUri = newBaseUri;
        _paymentToken = newPaymentToken;
        _tokenPrice = newInitialTokenPrice;
        _totalSupply = 0;
    }

    function mint(address to) external {
        require(
            _paymentToken.allowance(msg.sender, address(this)) >= _tokenPrice,
            "insufficient allowance"
        );
        uint256 tokenId = _totalSupply + 1;
        _totalSupply += tokenId;
        _balances[to] += 1;
        _owners[tokenId] = to;
        _paymentToken.transferFrom(msg.sender, address(0), _tokenPrice);
        emit Transfer(address(0), to, tokenId);
        _tokenPrice += _tokenPrice / 10;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _owners[_tokenId];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        require(_from == _owners[_tokenId]);
        require(
            msg.sender == _owners[_tokenId] ||
                msg.sender == _approvals[_tokenId] ||
                this.isApprovedForAll(_owners[_tokenId], msg.sender),
            "not authorized"
        );
        _approvals[_tokenId] = address(0);
        _balances[_from] -= 1;
        _owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external {
        require(msg.sender == _owners[_tokenId], "not authorized");
        _approvals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return _approvals[_tokenId];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return string.concat(_baseUri, StringUtils.toString(_tokenId));
    }

    // Bonus functions

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return interfaceID == 0x80ac58cd;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external {
        require(
            _from == _owners[_tokenId],
            "_from does not own token _tokenId"
        );
        require(
            msg.sender == _owners[_tokenId] ||
                msg.sender == _approvals[_tokenId] ||
                _fullApprovals[_owners[_tokenId]][msg.sender],
            "not authorized"
        );
        require(_to != address(0), "can't send to 0x0");
        require(_tokenId <= _totalSupply, "invalid tokenId");
        _approvals[_tokenId] = address(0);
        _balances[_from] -= 1;
        _owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
        uint256 _toSize;
        assembly {
            _toSize := extcodesize(_to)
        }
        if (_toSize > 0) {
            (, bytes memory result) = _to.staticcall(
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)",
                    _from,
                    _to,
                    _tokenId,
                    data
                )
            );
            if (bytes4(result) != 0x150b7a02) {
                revert("magic value not returned");
            }
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        require(
            _from == _owners[_tokenId],
            "_from does not own token _tokenId"
        );
        require(
            msg.sender == _owners[_tokenId] ||
                msg.sender == _approvals[_tokenId] ||
                _fullApprovals[_owners[_tokenId]][msg.sender],
            "not authorized"
        );
        require(_to != address(0), "can't send to 0x0");
        require(_tokenId <= _totalSupply, "invalid tokenId");
        _approvals[_tokenId] = address(0);
        _balances[_from] -= 1;
        _owners[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
        uint256 _toSize;
        assembly {
            _toSize := extcodesize(_to)
        }
        if (_toSize > 0) {
            (, bytes memory result) = _to.staticcall(
                abi.encodeWithSignature(
                    "onERC721Received(address,address,uint256,bytes)",
                    _from,
                    _to,
                    _tokenId,
                    ""
                )
            );
            if (bytes4(result) != 0x150b7a02) {
                revert("magic value not returned");
            }
        }
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _fullApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return _fullApprovals[_owner][_operator];
    }
}
