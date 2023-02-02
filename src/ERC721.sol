// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC20.sol";
import "./interfaces/IERC721.sol";

contract ERC721 is IERC721Metadata {
    constructor(
        string memory name,
        string memory symbol,
        string memory baseUri,
        IERC20 paymentToken,
        uint256 initialTokenPrice
    ) {}

    function mint(address to) external {}

    function balanceOf(address _owner) external view returns (uint256) {}

    function ownerOf(uint256 _tokenId) external view returns (address) {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {}

    function approve(address _approved, uint256 _tokenId) external {}

    function getApproved(uint256 _tokenId) external view returns (address) {}

    function name() external view returns (string memory _name) {}

    function symbol() external view returns (string memory _symbol) {}

    function tokenURI(uint256 _tokenId) external view returns (string memory) {}

    // Bonus functions

    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool)
    {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {}

    function setApprovalForAll(address _operator, bool _approved) external {}

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {}
}
