// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Epoch Merkle distribution
/// @notice Independently funded ERC20 distribution epochs with double-hashed leaves and per-index replay protection.
/// @dev Reference implementation; independent audit required before production.

contract EpochDistributor is SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    struct Epoch {
        bytes32 root;
        uint256 remaining;
        uint64 deadline;
        address funder;
    }
    mapping(uint256 => Epoch) public epochs;
    mapping(uint256 => mapping(uint256 => uint256)) private claimedWords;
    event EpochCreated(
        uint256 indexed epoch,
        bytes32 root,
        uint256 budget,
        uint64 deadline
    );
    event Claimed(
        uint256 indexed epoch,
        uint256 indexed index,
        address indexed account,
        uint256 amount
    );
    event Reclaimed(uint256 indexed epoch, uint256 amount);
    constructor(address asset, address admin) SuiteBase(admin) {
        require(asset.code.length > 0, "asset");
        token = IERC20(asset);
    }
    function leaf(
        uint256 epoch,
        uint256 index,
        address account,
        uint256 amount
    ) public pure returns (bytes32) {
        return
            keccak256(
                bytes.concat(
                    keccak256(abi.encode(epoch, index, account, amount))
                )
            );
    }
    function createEpoch(
        uint256 epoch,
        bytes32 root,
        uint256 budget,
        uint64 deadline
    ) external nonReentrant whenNotPaused {
        require(
            epochs[epoch].funder == address(0) &&
                root != bytes32(0) &&
                budget > 0 &&
                deadline > block.timestamp,
            "epoch"
        );
        AssetFlow.pullExact(token, msg.sender, budget);
        epochs[epoch] = Epoch(root, budget, deadline, msg.sender);
        emit EpochCreated(epoch, root, budget, deadline);
    }
    function isClaimed(
        uint256 epoch,
        uint256 index
    ) public view returns (bool) {
        return claimedWords[epoch][index / 256] & (1 << (index % 256)) != 0;
    }
    function claim(
        uint256 epoch,
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external nonReentrant {
        Epoch storage e = epochs[epoch];
        require(
            e.funder != address(0) &&
                block.timestamp < e.deadline &&
                account != address(0) &&
                amount > 0 &&
                !isClaimed(epoch, index),
            "claim"
        );
        require(
            MerkleProof.verifyCalldata(
                proof,
                e.root,
                leaf(epoch, index, account, amount)
            ),
            "proof"
        );
        require(amount <= e.remaining, "budget");
        claimedWords[epoch][index / 256] |= 1 << (index % 256);
        e.remaining -= amount;
        token.safeTransfer(account, amount);
        emit Claimed(epoch, index, account, amount);
    }
    function reclaim(uint256 epoch) external nonReentrant {
        Epoch storage e = epochs[epoch];
        require(
            e.funder == msg.sender && block.timestamp >= e.deadline,
            "reclaim"
        );
        uint256 amount = e.remaining;
        e.remaining = 0;
        token.safeTransfer(msg.sender, amount);
        emit Reclaimed(epoch, amount);
    }
}
