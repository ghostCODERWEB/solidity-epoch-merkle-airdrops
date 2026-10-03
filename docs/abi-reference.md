# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address asset,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Claimed(uint256 epoch,uint256 index,address account,uint256 amount)` | event |  |  |
| `EpochCreated(uint256 epoch,bytes32 root,uint256 budget,uint64 deadline)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Reclaimed(uint256 epoch,uint256 amount)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `claim(uint256 epoch,uint256 index,address account,uint256 amount,bytes32[] proof)` | function | nonpayable |  |
| `createEpoch(uint256 epoch,bytes32 root,uint256 budget,uint64 deadline)` | function | nonpayable |  |
| `epochs(uint256 )` | function | view | bytes32 root, uint256 remaining, uint64 deadline, address funder |
| `isClaimed(uint256 epoch,uint256 index)` | function | view | bool  |
| `leaf(uint256 epoch,uint256 index,address account,uint256 amount)` | function | pure | bytes32  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `reclaim(uint256 epoch)` | function | nonpayable |  |
| `renounceOwnership()` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `token()` | function | view | address  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
