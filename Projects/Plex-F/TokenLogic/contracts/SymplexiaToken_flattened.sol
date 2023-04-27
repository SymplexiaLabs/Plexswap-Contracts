
// File: Projects/Plex-F/TokenLogic/contracts/ISalesVault.sol


pragma solidity ^0.8.11;

interface ISalesVault {

    function baseToken() external view returns (address);

}
// File: Projects/Plex-F/TokenLogic/contracts/ILiquidityVault.sol


pragma solidity ^0.8.11;

interface ILiquidityVault {

    function autoLiquidity(uint256 _numTokensToLiquidity) external returns(uint256, uint256);

    function getTokenPrice() external view returns(uint256);

    function isInitialized() external view returns (bool);

    function isAddingLiquidity() external view returns (bool);

    function liquidityPair() external view returns (address);

    function baseToken() external view returns (address);

    function contractManager() external view returns (address);

    function externalSafe() external view returns (address);
}
// File: Projects/Plex-F/TokenLogic/contracts/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: Projects/Plex-F/TokenLogic/contracts/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.11;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: Projects/Plex-F/TokenLogic/contracts/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.11;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: Projects/Plex-F/TokenLogic/contracts/BasicAccessControl.sol



pragma solidity ^0.8.11;


abstract contract BasicAccessControl is Context {
    struct RoleData {
        mapping(address => bool) members;
        uint8 adminRole;
    }

    mapping(uint8 => RoleData) private _roles;

    event RoleAdminChanged (uint8 indexed role, uint8 indexed previousAdminRole, uint8 indexed newAdminRole);
    event RoleGranted (uint8 indexed role, address indexed account, address indexed sender);
    event RoleRevoked (uint8 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(uint8 role) {
        require(hasRole(role, _msgSender()), "Caller has not the needed Role");
        _;
    }

    function hasRole(uint8 role, address account) public view returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(uint8 role) public view returns (uint8) {
        return _roles[role].adminRole;
    }

    function grantRole(uint8 role, address account) public virtual onlyRole (getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(uint8 role, address account) public virtual onlyRole (getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(uint8 role, address account) public virtual {
         require(account == _msgSender(), "Can only renounce roles for self");
        _revokeRole(role, account);
    }

    function _setupRole(uint8 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(uint8 role, uint8 adminRole) internal virtual {
        uint8 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(uint8 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(uint8 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: Projects/Plex-F/TokenLogic/contracts/PausableUpgradable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.11;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

//   ======================================
//             Initialize Function             
//   ====================================== 

    function _Pausable_init () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: Projects/Plex-F/TokenLogic/contracts/OwnableUpgradable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.11;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function _Ownable_init () internal {
	_transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: Projects/Plex-F/TokenLogic/contracts/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.11;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: Projects/Plex-F/TokenLogic/contracts/Initializable.sol


// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.11;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// File: Projects/Plex-F/TokenLogic/contracts/SymplexiaLib.sol

//SPDX-License-Identifier: MIT


pragma solidity ^0.8.11;


    address  constant wicksellReserves      = 0x105457181764615639126242800330228074FEeD;
    address  constant goldenBonus           = 0x161803398874989484820458683436563811Feed;
    address  constant loyaltyRewards        = 0x241421356237309504880168872420969807fEED;
    address  constant dividendReserves      = 0x27182818284590452353602874713527FEEdCAFE;
    address  constant corporateAssets       = 0x577215664901532860606512090082402431FEED; 
    address  constant regulatoryFunds       = 0x132471795724474602596090885447809734fEEd;

    uint32  constant _baseSupply            = 1500000000;  
    uint16  constant tenK                   = 10000;
    uint16  constant bonusFee               = 450;
    uint16  constant liquidityFee           = 300;
    uint16  constant projectFee             = 200;                     
    uint16  constant contingencyFee         = 50;
    uint16  constant maxDynamicFee          = 500;
    uint16  constant minDynamicFee          = 50;
    uint8   constant _decimals              = 9;

    uint48   constant _sellRange            = 30  minutes;
    uint48   constant _loyaltyRange         = 180 days;
    uint48   constant _burnRange            = 90  days;
    uint48   constant _releaseRange         = 7   days;

    uint256  constant _minimumSupply        = ((_baseSupply * 2) / 3 ) * 10**_decimals;
    uint256  constant _maxWalletBalance     = ( _baseSupply / 100    ) * 10**_decimals;     // 1% of the total supply
    uint256  constant _maxTokensPerTx       = ( _baseSupply / 200    ) * 10**_decimals;     // 0.5% of  Tokens Supply

//  Basic Roles

    uint8 constant Contract_Manager         = 1;
    uint8 constant Financial_Controller     = 11;
    uint8 constant Compliance_Auditor       = 12;
    uint8 constant Distributor_Agent        = 13;
    uint8 constant Treasury_Analyst         = 111; 

//  Type of Accounts

    uint8 constant Ordinary                 = 0;
    uint8 constant Internal                 = 1;
    uint8 constant Contributor              = 2;
    uint8 constant Partner                  = 3;

//  Type of Vaults

    uint8 constant Project                  = 1;
    uint8 constant Contingency              = 2;
    uint8 constant Liquidity                = 3;

library SymplexiaLib {

    using  Address  for address;

    struct AccountInfo  {uint256 balance; uint48 lastTxn; uint48 nextMilestone; uint48 headFutureAssets;
                         uint8 accType; bool isTaxFree; bool isNonBonus; bool isLocked; bool isUnrewardable; }

    struct AssetsInfo   {uint256 balance; uint48 releaseTime;}

    struct TradingInfo  {uint256 buyingStack; uint256 sellingStack; uint256 lastTokenPrice;
                         uint256 lastTxnValue; uint8 lastTxnType; bool needAttenuation;
    }

    struct FeesInfo   {
           uint256 Liquidity;
           uint256 Funds;
           uint256 Bonus;
           uint256 Burn;
           uint256 WicksellReserves;
           uint256 LoyaltyRewards;
           uint256 Project;
           uint256 Contingency;
    }   

    struct InventoryStorage {
    	mapping (address => AccountInfo) Basis;
    	mapping (address => mapping (uint48 => AssetsInfo)) futureAssets;
        address[]   noBonusList;
        address[]   partnersList;
    	uint256     tokensSupply;
        TradingInfo tradingTrack;  
        bool        isBurnable;
    }

    event TokensBurnt            (address account,    uint256 burnAmount);
    event WicksellReservesBurned (address authorizer, uint256 burnAmount);
    event FutureAssetsReleased   (address _recipient, uint256 _amountReleased);
    event CorporateAssetsShared  (address authorizer, address beneficiary, uint256 amount);
    event UnfitAccountSet        (address authorizer, address unfitTrader, uint256 _balance);
    event SetBonusStatus         (address authorizer, address account, bool status);
    event RewardsClaimed         (address account,    uint256 amountRewards);  
    event AssetsSentAndFrozen    (address _sender,    address _recipient, uint64 _freezeDuration, uint256 _amountToFreeze);
    event FeesTransfered         (uint256 Liquidity, uint256 Contingency, uint256 Project, uint256 Bonus, uint256 LoyaltyRewards, uint256 WicksellReserves, uint256 Burn );

 //-------------------------------------------------------------------------

    function balanceOf (InventoryStorage storage self, address account) public view returns (uint256) {
        return self.Basis[account].balance + getBonus(self, account);
    }
 //-------------------------------------------------------------------------

   /***************************************************************************************
     *  NOTE:
     *  The following functions help to configure the special attributes of some accounts,
     *  in other cases those attributes are configured as default.
   ****************************************************************************************/
    function addInNoBonusList (InventoryStorage storage self, address account) internal {
        bool alreadyIncluded;
        for (uint256 i=0; i < self.noBonusList.length; i++) {
            if (self.noBonusList[i] == account) {
                alreadyIncluded = true;
                break;
            }
        }
        if (!alreadyIncluded) {self.noBonusList.push(account);}
    }
//-----------------------------------------------------------------------------
    function setInternalStatus (InventoryStorage storage self, address account, bool isLocked) public {
        self.Basis[account].accType        = Internal;
        self.Basis[account].isTaxFree      = true;
        self.Basis[account].isLocked       = isLocked;
        self.Basis[account].isNonBonus     = true;
        self.Basis[account].isUnrewardable = true;
        addInNoBonusList(self, account);
    }
//-----------------------------------------------------------------------------

    function excludeFromBonus (InventoryStorage storage self, address sender, address account) public {
        require(!self.Basis[account].isNonBonus, "Already non-bonus" );
        require(account != wicksellReserves,     "Cannot be excluded");
        uint256 _bonus = getBonus(self, account); 
        self.Basis[account].balance     += _bonus;
        self.Basis[goldenBonus].balance -= _bonus;
        self.Basis[account].isNonBonus   = true;
        addInNoBonusList(self, account);
        emit SetBonusStatus (sender, account, true);
    }
//-----------------------------------------------------------------------------

    function includeInBonus (InventoryStorage storage self, address Sender, address account) public {
        require(  self.Basis[account].isNonBonus, "Already receive bonus");
        
        (uint256 _adjustedBonus, uint256 _adjustedBalance) = shareAmount(self, self.Basis[account].balance);
        for (uint256 i = 0; i < self.noBonusList.length; i++) {
            if (self.noBonusList[i] == account) {
                self.noBonusList[i] = self.noBonusList[self.noBonusList.length - 1];
                self.Basis[account].isNonBonus   = false;
                self.Basis[account].balance      = _adjustedBalance;
                self.Basis[goldenBonus].balance += _adjustedBonus;
                self.noBonusList.pop();
                break;
            }
        }
        emit SetBonusStatus (Sender, account, false);
    }
   /***************************************************************************************
     *  NOTE:
     *  The "shareDividends" and "_partnersBalance" functions distribute 
     *  the dividends among the current Partners.  
   ****************************************************************************************/

    function partnersBalance (InventoryStorage storage self) public view returns (uint256) {
        uint256 _partnersBalance;
        uint256 _unfrozenAmount;
        uint256 _frozenAmount;

        for (uint256 i=0; i < self.partnersList.length; i++){
            (_unfrozenAmount, _frozenAmount,) = futureAssetsBalance(self, self.partnersList[i]);
            _partnersBalance += (_unfrozenAmount + _frozenAmount);
        }
        return  _partnersBalance;                 
    }

    function shareDividends (InventoryStorage storage self) public {
       uint256 _partnersBalance  = partnersBalance(self);
       uint256 _dividendReserves = self.Basis[dividendReserves].balance;
       uint256 _eligibleBalance;
       uint256 _calcDividend;
       uint256 _bonusSlice;
       uint256 _balanceSlice;
       uint256 _unfrozenAmount;
       uint256 _frozenAmount;

       for (uint256 i=0; i < self.partnersList.length; i++){
            (_unfrozenAmount, _frozenAmount,) = futureAssetsBalance (self, self.partnersList[i]);
            _eligibleBalance = _unfrozenAmount + _frozenAmount;
            _calcDividend     = (_dividendReserves * _eligibleBalance) / _partnersBalance;
            (_bonusSlice, _balanceSlice)  = shareAmount(self, _calcDividend);
            self.Basis[self.partnersList[i]].balance     +=  _balanceSlice;
            self.Basis[goldenBonus].balance              +=  _bonusSlice;
            self.Basis[dividendReserves].balance         -=  _calcDividend; 
        }
        
        if (self.Basis[dividendReserves].balance > 0 ) {
            self.Basis[wicksellReserves].balance += self.Basis[dividendReserves].balance;
            self.Basis[dividendReserves].balance = 0;
        }
    }
   /***************************************************************************************
     *  NOTE:
     *  The "calcDynamicFee" and "collectFees" functions  help to final calculate and  
     *  collect all due fees. 
   ****************************************************************************************/ 
 function calcDynamicFee (InventoryStorage storage self, address account, 
                          uint256 sellAmount, uint16 efficiencyFactor) public returns (uint256 dynamicFee) {
         
        uint256 reduceFee;
        uint256 sellQuocient; 
        uint256 reduceFactor;

        dynamicFee = self.Basis[account].balance * maxDynamicFee * efficiencyFactor / self.tokensSupply;
       
        if (dynamicFee > maxDynamicFee) {dynamicFee = maxDynamicFee;}
        if (dynamicFee < minDynamicFee) {dynamicFee = minDynamicFee;}
        
        if (self.Basis[account].lastTxn + _sellRange < block.timestamp) {
            sellQuocient = (sellAmount * tenK) / self.Basis[account].balance;
            reduceFactor = (sellQuocient > 1000) ? 0 : (1000 - sellQuocient);
            reduceFee    = (reduceFactor * 30) / 100;
            dynamicFee  -= reduceFee;
        }

        self.Basis[account].lastTxn = uint48(block.timestamp);
    }

   function collectFees (InventoryStorage storage self,
                         uint256 _tAmount, uint256 _liquidityFee, 
                         uint256 _deflatFee, uint256 _wicksellFee, 
                         uint256 _loyaltyRewardsFee, uint256 _contingencyFee, 
                         uint256 _bonusFee, uint256 _projectFee, 
                         address liquidityVault, 
                         address contingencyVault, 
                         address projectVault) public returns (uint256 totalFees) {
       
        FeesInfo memory fees;

        fees.Liquidity            = (_tAmount * _liquidityFee) / tenK;
        fees.Burn                 = (_tAmount * _deflatFee) / tenK;
        fees.WicksellReserves     = (_tAmount * _wicksellFee) / tenK;
        fees.LoyaltyRewards       = (_tAmount * _loyaltyRewardsFee) / tenK;
        fees.Contingency          = (_tAmount * _contingencyFee) / tenK;
        fees.Bonus                = (_tAmount * _bonusFee) / tenK;
        fees.Project              = (_tAmount * _projectFee) / tenK;

        self.Basis[liquidityVault].balance          +=  fees.Liquidity; 
        self.Basis[contingencyVault].balance  +=  fees.Contingency;
        self.Basis[projectVault].balance      +=  fees.Project;
        self.Basis[goldenBonus].balance            +=  fees.Bonus;
        self.Basis[loyaltyRewards].balance         +=  fees.LoyaltyRewards;
        if (self.isBurnable) {
            self.Basis[wicksellReserves].balance   +=  fees.WicksellReserves; 
            self.tokensSupply                      -=  fees.Burn;
            if (self.tokensSupply - self.Basis[wicksellReserves].balance <= _minimumSupply ) {
               self.isBurnable = false;
            }
        }  
        emit FeesTransfered(fees.Liquidity, fees.Contingency, fees.Project, fees.Bonus, fees.LoyaltyRewards, fees.WicksellReserves, fees.Burn );
    
        totalFees = fees.Liquidity + fees.Burn + fees.WicksellReserves + fees.LoyaltyRewards + 
                    fees.Contingency + fees.Bonus + fees.Project;
    }

   /***************************************************************************************
     *  NOTE:
     *  The "getBonus", "shareAmount" and "bonusBalances" functions help to redistribute 
     *  the specified  amount of Bonus among the current holders via an special algorithm  
     *  that eliminates the need for interaction with all holders account. 
   ****************************************************************************************/   

    function bonusBalances (InventoryStorage storage self) public view returns (uint256) {
        uint256 expurgedBalance;
        for (uint256 i=0; i < self.noBonusList.length; i++){
            expurgedBalance += self.Basis[self.noBonusList[i]].balance;
        }
        return  self.tokensSupply - expurgedBalance;                 
    }

    function getBonus (InventoryStorage storage self, address account) public view returns (uint256) {
        if ( self.Basis[account].isNonBonus || self.Basis[goldenBonus].balance == 0 || self.Basis[account].balance == 0 ){
            return 0;
        } else {
            uint256 shareBonus = (self.Basis[goldenBonus].balance * self.Basis[account].balance) / bonusBalances (self);
            return  shareBonus;
        }
    }

    function shareAmount (InventoryStorage storage self, uint256 tAmount) public returns (uint256, uint256) {
        uint256 _eligibleBalance = bonusBalances(self);
        if (self.Basis[goldenBonus].balance == 0) return (0, tAmount);
        if (_eligibleBalance == 0) { 
            self.Basis[loyaltyRewards].balance += self.Basis[goldenBonus].balance;
            self.Basis[goldenBonus].balance = 0;
            return (0, tAmount);
        } 

        uint256 _bonusStock   = self.Basis[goldenBonus].balance;
        uint256 _bonusAmount  = (tAmount * _bonusStock) / (_eligibleBalance + _bonusStock);
        uint256 _rawAmount    = tAmount - _bonusAmount; 
        return (_bonusAmount, _rawAmount);
    }
//------------------------------------------------------------------

   function investorBurn (InventoryStorage storage self, address Sender, uint256 burnAmount) public { 
        require(self.isBurnable, "Not burnable");
        require(self.Basis[Sender].accType != Internal, "Internal Address");
        burnAmount = burnAmount * (10**_decimals);
        require(burnAmount <= balanceOf(self, Sender),  "Insuficient balance");

         // Balance without the part reffering to bonus (Bonus is never burned!!)
        if (burnAmount > self.Basis[Sender].balance) {burnAmount = self.Basis[Sender].balance; }   
        
        uint256 rewardsAmount = burnAmount / 5;
        uint256 deadAmount    = burnAmount - rewardsAmount;

        self.Basis[Sender].balance           -= burnAmount;
        self.Basis[loyaltyRewards].balance   += rewardsAmount;
        self.Basis[wicksellReserves].balance += deadAmount;
        
        if (self.tokensSupply - self.Basis[wicksellReserves].balance <= _minimumSupply ) {
            self.isBurnable = false;
        }

        emit TokensBurnt (Sender, burnAmount);  
    }
//-------------------------------------------------------------------------

    function wicksellBurn (InventoryStorage storage self, address Sender) public {
        require (self.Basis[wicksellReserves].balance > 0, "Zero balance");
        require (self.Basis[wicksellReserves].lastTxn + 30 days < block.timestamp, "Time elapsed too short");
        uint256 elapsedTime  = _burnRange + block.timestamp - self.Basis[wicksellReserves].nextMilestone;
        uint256 burnAmount;
       
        if (self.isBurnable) {
            if (elapsedTime > _burnRange) { 
                 burnAmount = self.Basis[wicksellReserves].balance;                                // Balance without the part reffering to bonus
                 self.Basis[wicksellReserves].nextMilestone = uint48(block.timestamp + _burnRange);
            } else {
                 burnAmount = (self.Basis[wicksellReserves].balance * elapsedTime) / _burnRange;
            }

            self.Basis[wicksellReserves].lastTxn  = uint48(block.timestamp);
            self.Basis[wicksellReserves].balance -= burnAmount;                                    // Burn only the raw balance, without the bonus
            self.tokensSupply                    -= burnAmount;
        } else{
            uint256 _residueBurn = (self.Basis[wicksellReserves].balance + _minimumSupply) - self.tokensSupply;
            self.Basis[goldenBonus].balance += _residueBurn;
            delete self.Basis[wicksellReserves];
            self.tokensSupply = _minimumSupply;
        }

        emit WicksellReservesBurned (Sender, burnAmount);
    }
//-----------------------------------------------------------------------------

   function sendAndFreeze (InventoryStorage storage self, address _sender, address _recipient, uint256 _amountToFreeze, uint64 _freezeDuration) public {
        _amountToFreeze *= (10  **_decimals);

        require((!self.Basis[_sender].isLocked && self.Basis[_sender].accType != Internal) || 
                 _sender == corporateAssets, "Sender locked");

        require( !self.Basis[_recipient].isLocked && 
                  self.Basis[_recipient].accType != Internal, "Recipient not allowed");
                  
        require(balanceOf(self, _sender) >= _amountToFreeze,  "Balance insufficient");

        (uint256 bonusSlice, uint256 balanceSlice)  = shareAmount(self, _amountToFreeze);

        if (_sender == corporateAssets) {
            self.Basis[_sender].balance     -= _amountToFreeze;
            self.Basis[goldenBonus].balance += bonusSlice; 
        } else {
            self.Basis[_sender].balance     -= balanceSlice;
        }
        freezeAssets (self, _recipient, balanceSlice, _freezeDuration);
        emit AssetsSentAndFrozen (_sender, _recipient, _freezeDuration, _amountToFreeze);
    }
//-----------------------------------------------------------------------------

    function freezeAssets (InventoryStorage storage self, address _recipient, uint256 _amountToFreeze, uint64 _freezeDuration) public {
        uint48 _currentRelease;                                                                                               
        uint48 _freezeTime = uint48((block.timestamp + _freezeDuration * 86400) / 86400);     
        uint48 _nextRelease = self.Basis[_recipient].headFutureAssets;

        if (_nextRelease == 0 || _freezeTime < _nextRelease ) { 
           self.Basis[_recipient].headFutureAssets               = _freezeTime;
           self.futureAssets[_recipient][_freezeTime].balance     = _amountToFreeze;
           self.futureAssets[_recipient][_freezeTime].releaseTime = _nextRelease;
           return; 
        }

        while (_nextRelease != 0 && _freezeTime > _nextRelease ) {
            _currentRelease    = _nextRelease;
            _nextRelease = self.futureAssets[_recipient][_currentRelease].releaseTime;
        }

        if (_freezeTime == _nextRelease) {
            self.futureAssets[_recipient][_nextRelease].balance += _amountToFreeze; 
            return;
        }

        self.futureAssets[_recipient][_currentRelease].releaseTime = _freezeTime;
        self.futureAssets[_recipient][_freezeTime].balance         = _amountToFreeze;
        self.futureAssets[_recipient][_freezeTime].releaseTime     = _nextRelease;
    }
//-----------------------------------------------------------------------------

   function setUnfitAccount (InventoryStorage storage self, address Sender, address _unfitTrader) public {  
        require(self.Basis[_unfitTrader].isLocked, "Account not Blocked");
        require(!self.Basis[_unfitTrader].isNonBonus, "Account without Bonus");
        uint256 _bonusUnfit = getBonus(self, _unfitTrader);
        require(_bonusUnfit > 0, "Zero Earnings");
          
        excludeFromBonus(self, Sender, _unfitTrader);            // Exclude the account from future Bonus
        self.Basis[_unfitTrader].isUnrewardable = true;          // Exclude the account from future Rewards
        self.Basis[_unfitTrader].isLocked       = false;         // Release the account for Financial Movement 
        self.Basis[_unfitTrader].balance       -= _bonusUnfit;
 
        // Half of unfit earnings is frozen for 180 days and the other half for 3 years
        uint256 _shortFreeze    = _bonusUnfit / 2;
        uint256 _longFreeze     = _bonusUnfit - _shortFreeze;

        freezeAssets (self, _unfitTrader, _shortFreeze, 180);                   // Freeze half earnings for 180 days
        freezeAssets (self, _unfitTrader, _longFreeze, 1095);                   // Freeze the other half for 3 years
 
        emit UnfitAccountSet(Sender, _unfitTrader, _bonusUnfit);
    }
//-----------------------------------------------------------------------------

   function releaseFutureAssets (InventoryStorage storage self, address Sender) public {
        uint256 _frozenAmount;
        uint48  _nextRelease = self.Basis[Sender].headFutureAssets;
        uint48  _currentTime = uint48(block.timestamp/86400);
        uint48  _currentNode;
        require(_nextRelease != 0 && _currentTime > _nextRelease, "Zero releases");   

        while (_nextRelease != 0 && _currentTime > _nextRelease) {
               _frozenAmount += self.futureAssets[Sender][_nextRelease].balance;
               _currentNode   = _nextRelease;
               _nextRelease   = self.futureAssets[Sender][_currentNode].releaseTime;
                delete self.futureAssets[Sender][_currentNode];
        }

        self.Basis[Sender].headFutureAssets = _nextRelease;

        (uint256 bonusSlice, uint256 balanceSlice) = shareAmount(self, _frozenAmount);
        self.Basis[Sender].balance                +=  balanceSlice;
        self.Basis[goldenBonus].balance           +=  bonusSlice;

        emit FutureAssetsReleased(Sender, _frozenAmount);
    }
//-----------------------------------------------------------------------------

    function futureAssetsBalance (InventoryStorage storage self, address _recipient) public view returns (uint256 _unfrozenAmount, uint256 _frozenAmount, uint256 _futureBonus) {
        uint48 _currentTime = uint48(block.timestamp/86400);    
        uint48 _nextRelease = self.Basis[_recipient].headFutureAssets;
        uint48 _currentNode;

        while (_nextRelease != 0 ) {
             if (_currentTime > _nextRelease) {
              _unfrozenAmount += self.futureAssets[_recipient][_nextRelease].balance;
             } else {
              _frozenAmount   += self.futureAssets[_recipient][_nextRelease].balance;  
             }
              _currentNode     = _nextRelease;
              _nextRelease     = self.futureAssets[_recipient][_currentNode].releaseTime;
        }
        
        _futureBonus = (self.Basis[goldenBonus].balance * (_frozenAmount + _unfrozenAmount)) / bonusBalances(self);

        _frozenAmount   /= (10 ** _decimals);
        _unfrozenAmount /= (10 ** _decimals);
        _futureBonus    /= (10 ** _decimals);
    } 

//-----------------------------------------------------------------------------
    function claimLoyaltyRewards (InventoryStorage storage self, address Sender) public { 
        require (!self.Basis[Sender].isNonBonus && !self.Basis[Sender].isLocked &&
                 !self.Basis[Sender].isUnrewardable,"Not eligible");
        require ( self.Basis[Sender].nextMilestone <= block.timestamp, "Not available yet"); 

        uint256 releasedRewards = (getBonus(self, Sender) * self.Basis[loyaltyRewards].balance) / self.Basis[goldenBonus].balance;
        (uint256 bonusSlice, uint256 balanceSlice) = shareAmount(self, releasedRewards);

        self.Basis[Sender].balance         +=  balanceSlice;
        self.Basis[goldenBonus].balance    +=  bonusSlice;

        self.Basis[loyaltyRewards].balance -= releasedRewards;
        self.Basis[Sender].isUnrewardable   = true;

        emit RewardsClaimed (Sender, releasedRewards);  
    }
//-----------------------------------------------------------------------------

    function updateStack (InventoryStorage storage self, address liquidityPair, uint256 _newTokenPrice) public returns (uint256 _attenuationPoint) {  
        _attenuationPoint = self.Basis[liquidityPair].balance / 10;

        if (self.tradingTrack.lastTxnType  > 2 ) return (_attenuationPoint) ;

        if (self.tradingTrack.lastTokenPrice != _newTokenPrice)  {
            if      (self.tradingTrack.lastTxnType == 1) {self.tradingTrack.buyingStack  += self.tradingTrack.lastTxnValue; }
            else if (self.tradingTrack.lastTxnType == 2) {self.tradingTrack.sellingStack += self.tradingTrack.lastTxnValue; }

            if (self.tradingTrack.buyingStack  >= self.tradingTrack.sellingStack) {
                self.tradingTrack.buyingStack  -= self.tradingTrack.sellingStack;
                self.tradingTrack.sellingStack  = 0;  }
            else {
                self.tradingTrack.sellingStack -= self.tradingTrack.buyingStack;
                self.tradingTrack.buyingStack   = 0;  }
        }

        self.tradingTrack.needAttenuation = (self.tradingTrack.buyingStack >= _attenuationPoint);
        self.tradingTrack.lastTxnType  = 4;
        self.tradingTrack.lastTxnValue = 0;
    }

//-----------------------------------------------------------------------------

}
// File: Projects/Plex-F/TokenLogic/contracts/BaseToken.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.11;








/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */

contract BaseToken is  Context, IERC20, IERC20Metadata, Ownable, Initializable {
    using SymplexiaLib for SymplexiaLib.InventoryStorage;

    SymplexiaLib.InventoryStorage internal Inventory;

    mapping (address => mapping(address => uint256)) private _allowances;
  
    string  private           _name;
    string  private           _symbol;

    address public            contingencyFundsVault;
    address public            projectFundsVault;
    address public            liquidityVault;
    address public            authorizedDealer;
    uint16  internal          reducedLiquidityFee;                   // Initially 1%            (Depends on efficiencyFactor)
    uint16  internal          reducedBonusFee;                       // Initially 2%            (Depends on efficiencyFactor)
    uint16  internal          reducedProjectFee;                     // Initially 1%            (Depends on efficiencyFactor)
    uint16  public            efficiencyFactor;                      // Must be calibrated between 150 and 250 
    uint256 internal          _liquidityThreshold;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */


//   ======================================
//             Initialize Function             
//   ======================================

    function _BaseToken_init ( 	
                string memory name_, 
				string memory symbol_,
				address _projectFundsVault, 
				address _contingencyFundsVault ) internal initializer { 

        _name   = name_;
        _symbol = symbol_;

        projectFundsVault      = _projectFundsVault;
        contingencyFundsVault  = _contingencyFundsVault;
 	    Inventory.tokensSupply = (_baseSupply) * 10**_decimals;
        Inventory.isBurnable   = true;

       _Ownable_init ();
    }
//   ======================================
//             Hook Functions             
//   ======================================

    function _tokenTransfer (address, address, uint256, bool) internal virtual {}

//   ======================================
//   ======================================
//            IERC20 Functions             
//   ======================================
//   ======================================
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC20-decimals}.
     */
    function decimals() public pure override returns (uint8)   { return _decimals; }

     /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) { return Inventory.tokensSupply; }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) { }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual { }

    function _directTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual { }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }


    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

// File: Projects/Plex-F/TokenLogic/contracts/SymplexiaToken.sol

//SPDX-License-Identifier: MIT

/*
/ This code was developed to support the distribution of shares of The Symplexia Labs, 
/ so it contains a set of monetary concepts that support the company's business development. 
/ In particular, some monetary reserves were created (Wicksell Reserves and Regulatory Funds) 
/ that are linked to the WicksellBurn and FisherAttenuation methods, among others. These   
/ methods were named in tribute to two brilliant economists related to monetary concepts.
/ If you want to know more about Knut Wicksell and his influence in the monetary concepts 
/ follow this link https://en.wikipedia.org/wiki/Knut_Wicksell. The same way, if you want to
/ know more about Irving Fisher follow this link https://en.wikipedia.org/wiki/Irving_Fisher.
*/

pragma solidity ^0.8.11;




//    Interfaces   



//**********************************//
//        A D J U S T A B L E   
//**********************************//

abstract contract Adjustable is BasicAccessControl, Pausable, BaseToken {
    using SymplexiaLib for SymplexiaLib.InventoryStorage;

    bool      public   allowSecurityPause;
    bool      internal isAdjustable;

    event NumTokensToLiquidityUpdated(address authorizer, uint256 _liquidityThreshold);
    event MaxTokensPerTxUpdated(address authorizer, uint256 _maxTokensPerTx);
    event VaultUpdated(address authorizer, uint8 id, address liquidityVault);
    event DealerAutorized (address authorizer, address liquidityVault, uint256 amount);
    event EfficiencyFactorUpdated (address authorizer, uint16 _newValue);
    event NoBonusListCkecked (bool fixApplied);

//   ======================================
//             Initialize Function             
//   ======================================

    function _Adjustable_init () internal initializer { 

       _setupRole(Contract_Manager,     _msgSender());
       _setupRole(Financial_Controller, _msgSender());
       _setupRole(Compliance_Auditor,   _msgSender());
       _setupRole(Treasury_Analyst,     _msgSender());
       _setupRole(Distributor_Agent,    _msgSender());

       _setRoleAdmin(Contract_Manager,     Contract_Manager);
       _setRoleAdmin(Financial_Controller, Contract_Manager);
       _setRoleAdmin(Distributor_Agent,    Contract_Manager);
       _setRoleAdmin(Compliance_Auditor,   Contract_Manager);
       _setRoleAdmin(Treasury_Analyst,     Financial_Controller); 

       isAdjustable          = true;
       allowSecurityPause    = true;
       _Pausable_init (); 
    }

//   ======================================
//             Internal Functions             
//   ======================================
    function _setEfficiencyFactor (uint16 _newFactor) internal {
        efficiencyFactor       = _newFactor;
        reducedLiquidityFee    = efficiencyFactor / 2;      
        reducedBonusFee        = efficiencyFactor;
        reducedProjectFee      = efficiencyFactor / 2;              
        _liquidityThreshold    = Inventory.tokensSupply / (efficiencyFactor * 10); 	 
    }

    function _setVault (address _oldVault, address _newVault) internal {
        require (Inventory.Basis[_newVault].balance == 0,   "New vault not empty");

        Inventory.setInternalStatus (_newVault, false);
        Inventory.Basis[_oldVault].accType  = Ordinary;
        _directTransfer(_oldVault, _newVault, Inventory.Basis[_oldVault].balance);
    }

    function _directTransfer (address sender, address recipient, uint256 amount) internal override {
        require (Inventory.Basis[sender].balance >= amount,   "Insufficient balance");
        Inventory.Basis[sender].balance    -= amount;
        Inventory.Basis[recipient].balance += amount;
        emit Transfer(sender, recipient, amount);
     }
//   ======================================
//           Parameters Functions                    
//   ======================================

    function setEfficiencyFactor (uint16 _newValue) external onlyRole(Financial_Controller) {
        require (_newValue >= 150 && _newValue <= 250, "Thresholds Invalid");
        _setEfficiencyFactor (_newValue);
        emit EfficiencyFactorUpdated (_msgSender(), _newValue);
    }

    function setSpecialAccount (address _account, uint8 _newType) external onlyRole(Contract_Manager) {
        require ( Inventory.Basis[_account].accType  == Ordinary && 
                 (_newType == Contributor || _newType == Partner), "Invalid Type");
        Inventory.Basis[_account].accType =  _newType;
        if (_newType == Partner) { Inventory.partnersList.push(_account); }
    }

    function setProjectVault (address _newVault) external onlyRole(Contract_Manager) {
        _setVault(projectFundsVault, _newVault);
        projectFundsVault = _newVault;
        emit VaultUpdated(_msgSender(), Project, _newVault);
    } 

    function setContingencyVault (address _newVault) external onlyRole(Contract_Manager) {
        _setVault(contingencyFundsVault, _newVault);
        contingencyFundsVault = _newVault;
        emit VaultUpdated(_msgSender(), Contingency, _newVault);
    } 

    function authorizeDealer (address _newVault, uint256 _salesAmount) external onlyRole(Contract_Manager) {
        // Require "Sales Vault" to be linked to this contract
        require (ISalesVault(_newVault).baseToken() == address(this),"Vault not Linked");
        _setVault(authorizedDealer, _newVault);
        authorizedDealer = _newVault;

        _salesAmount *= (10 ** _decimals);
        _salesAmount  = ( _salesAmount <= balanceOf(_msgSender()) ? _salesAmount :  balanceOf(_msgSender()) );
       
        _directTransfer(_msgSender(), authorizedDealer, _salesAmount);
        _setupRole(Distributor_Agent, authorizedDealer);

        emit DealerAutorized(_msgSender(), authorizedDealer, _salesAmount);
    }
//   ======================================
//           Contingency Functions                    
//   ======================================

  // Called by the Compliance Auditor on emergency, allow begin or end an emergency stop
    function setSecurityPause (bool isPause) external onlyRole(Compliance_Auditor) {
        if (isPause)  {
            require (allowSecurityPause, "Pause not allowed.");
            _pause();
        } else {
            _unpause();  
        }
    }
 
  // Called by the Financial Controller to disable ability to begin or end an emergency stop
    function disableContingencyFeature() external onlyRole(Financial_Controller)  {
        allowSecurityPause = false;
    }

  // Called by the Contract Manager to fix de noBonusList in case of duplicated entries
    function fixNoBonusList () external  onlyRole(Contract_Manager) {
        bool fixApplied;
        for (uint256 entry=0; entry < Inventory.noBonusList.length; entry++) {

            for (uint256 i=entry+1; i < Inventory.noBonusList.length; i++) {

               if (Inventory.noBonusList[i] == Inventory.noBonusList[entry]) {
                   Inventory.noBonusList[i] = Inventory.noBonusList[Inventory.noBonusList.length - 1];
                   Inventory.noBonusList.pop();
                   fixApplied = true;
               }
            }
        }
        emit NoBonusListCkecked (fixApplied);
    }
//   ======================================
//           Information Functions                    
//   ====================================== 

    function liquidityThreshold () external view returns (uint256) {
        return _liquidityThreshold;
    }

    function getTokenPrice () public view returns (uint256) { 
        return ILiquidityVault(liquidityVault).getTokenPrice();
    }
    
    function maxWalletBalance () external pure returns (uint256) { 
        return _maxWalletBalance;
    }

    function noBonusAddresses () external view returns (address[] memory noBonusList) {
        noBonusList = Inventory.noBonusList;
    }

}
//**********************************//
//    F L O W - F L E X I B L E
//**********************************//
abstract contract  FlowFlexible is Adjustable {
    using SymplexiaLib for SymplexiaLib.InventoryStorage;

    event WarningListUpdated     (address authorizer, address _user, bool _status);
 
    function setNextMilestone (address account, uint256 txAmount) internal {
        uint256 elapsedTime  = _loyaltyRange + block.timestamp - Inventory.Basis[account].nextMilestone;
        uint256 adjustedTime = ( elapsedTime * Inventory.Basis[account].balance) / ( Inventory.Basis[account].balance + txAmount ); 
        Inventory.Basis[account].nextMilestone = uint48(block.timestamp + _loyaltyRange - adjustedTime);
        Inventory.Basis[account].lastTxn = uint48(block.timestamp);
    }
//   ======================================
//            Manageable Functions                    
//   ======================================
    function setWarningList (address _markedAccount, bool _status) external onlyRole(Treasury_Analyst) {
        require (Inventory.Basis[_markedAccount].accType != Internal, "Account immutable"); 
        Inventory.Basis[_markedAccount].isLocked = _status;
        if ( _status = true ) Inventory.Basis[_markedAccount].lastTxn = uint48(block.timestamp);
        emit WarningListUpdated(_msgSender(), _markedAccount, _status);
    }

    function WicksellBurn () external onlyRole(Treasury_Analyst) {
        Inventory.wicksellBurn (_msgSender()); 
    } 
//   ======================================
//            Investor Functions                    
//   ======================================

    function unlockMyAccount () external {
        require (Inventory.Basis[_msgSender()].accType != Internal && Inventory.Basis[_msgSender()].isLocked, "Not allowed");
        require (Inventory.Basis[_msgSender()].lastTxn + _releaseRange < block.timestamp,    "Not allowed yet"); 
        Inventory.Basis[_msgSender()].isLocked = false;
        emit WarningListUpdated(_msgSender(), _msgSender(), false);
    } 
}
//**********************************//
//   A U T O L I Q U I D I T Y
//**********************************//
abstract contract AutoLiquidity is Adjustable {
    using SymplexiaLib for SymplexiaLib.InventoryStorage;

    address             internal   _slotReserved_2;
    address             public      liquidityPair;
    bool                public      autoLiquidity;
    bool                internal   _slotReserved_3;
    
    event LiquidityIncreased(uint256 tradedTokens, uint256 tradedCoins, bool automatic);    
    event CoinsTransferred(address recipient, uint256 amountCoins);
    event AutoLiquiditySet (address authorizer, bool _status);

//   ======================================
//     To receive Coins              
//   ======================================

    receive() external payable {}                      			

//   ======================================
//          Internal Functions                    
//   ====================================== 

    function _increaseLiquidity(uint256 _amount, bool automatic) internal {
        _directTransfer(address(this), liquidityVault, _amount);    
        (uint256 tradedTokens, uint256 tradedCoins)  = ILiquidityVault(liquidityVault).autoLiquidity(_amount);
        emit LiquidityIncreased(tradedTokens, tradedCoins, automatic);
    }

    function _updateLiquidityPair () internal   {
      if ( liquidityPair != ILiquidityVault(liquidityVault).liquidityPair() ) {
        liquidityPair = ILiquidityVault(liquidityVault).liquidityPair();
        Inventory.setInternalStatus (liquidityPair,false);
        Inventory.Basis[liquidityPair].isTaxFree = false;
      }
    }
//   ======================================
//          External Functions                    
//   ======================================  

    function setLiquidityVault (address _newVault) external onlyRole(Contract_Manager) {
        // Require "Liquidity Vault" to be Initialized
        require (ILiquidityVault(_newVault).baseToken() == address(this), "Vault not Linked");
        require (ILiquidityVault(_newVault).isInitialized(), "Vault not Initialized");
        _setVault(liquidityVault, _newVault);
        liquidityVault =  _newVault;
        
        _updateLiquidityPair();
        emit VaultUpdated(_msgSender(), Liquidity, _newVault);
    } 

    function enableAutoLiquidity () external onlyRole(Treasury_Analyst) {
        // Require "Liquidity Vault" to be Initialized
        require (!autoLiquidity, "AutoLiquidity Already Enabled");
        require (liquidityVault != address(0), "Liquidity Vault not Informed");
        require (ILiquidityVault(liquidityVault).isInitialized(), "Vault not Initialized");
        if (Inventory.Basis[address(this)].balance >= _liquidityThreshold) { 
            _increaseLiquidity(_liquidityThreshold, true);
        }
        autoLiquidity = true;
        emit AutoLiquiditySet (_msgSender(), autoLiquidity);
    }

    function disableAutoLiquidity () external onlyRole(Treasury_Analyst) {
        require (autoLiquidity, "Auto Liquidity Already Disabled");
        if (Inventory.Basis[address(this)].balance >= _liquidityThreshold) { 
            _increaseLiquidity(_liquidityThreshold, true);
        }
        autoLiquidity = false;
        emit AutoLiquiditySet (_msgSender(), autoLiquidity);
    }

    function manualLiquidity () external onlyRole(Treasury_Analyst) {
        require (Inventory.Basis[address(this)].balance >= _liquidityThreshold, "Below liquidity threshold"); 
            _increaseLiquidity(_liquidityThreshold, false);
    }
        
    function transferCoins () external onlyRole(Treasury_Analyst) {
        require(address(this).balance > 0, "Zero Balance");
        uint256 amountToTransfer = address(this).balance;
        payable(liquidityVault).transfer(amountToTransfer);
        emit CoinsTransferred(liquidityVault, amountToTransfer);
    }
}
//**********************************//
//   T   A   X   A   B   L   E 
//**********************************//
abstract contract Taxable is  FlowFlexible, AutoLiquidity {
    using Address      for address;
    using SymplexiaLib for SymplexiaLib.InventoryStorage;

    struct AmountInfo {
           uint256 Inflow;
           uint256 Outflow;
    }

    struct BonusInfo  {
           uint256 Balance;
           uint256 Inflow;
           uint256 Outflow;
    }
     
    event SetTaxableStatus (address authorizer, address account, bool status);
//   ======================================
//             Initialize Function             
//   ======================================

    function _Taxable_init () internal initializer { 

        Inventory.Basis[corporateAssets].balance = _maxWalletBalance * 10;
        Inventory.Basis[regulatoryFunds].balance = _maxWalletBalance * 5;
        Inventory.Basis[_msgSender()].balance    = Inventory.tokensSupply - Inventory.Basis[corporateAssets].balance - Inventory.Basis[regulatoryFunds].balance;

        Inventory.setInternalStatus (owner(),               false);
        Inventory.setInternalStatus (address(this),         false);
        Inventory.setInternalStatus (projectFundsVault,     false);
        Inventory.setInternalStatus (contingencyFundsVault, false);
        Inventory.setInternalStatus (address(0),            true);
        Inventory.setInternalStatus (wicksellReserves,      true);
        Inventory.setInternalStatus (goldenBonus,           true);
        Inventory.setInternalStatus (loyaltyRewards,        true);
        Inventory.setInternalStatus (dividendReserves,      true);
        Inventory.setInternalStatus (corporateAssets,       true);
        Inventory.setInternalStatus (regulatoryFunds,       true); 

        // Additional Bonus generation strategy in the burning process
    
        Inventory.includeInBonus(_msgSender(),wicksellReserves);   

        // This factor calibrates the contract performance and the values of reduced fees 

        _setEfficiencyFactor (200);
        
        emit Transfer(address(0), _msgSender(), Inventory.tokensSupply);
    } 

//  =======================================
//        IERC20 Functions (OVERRIDE)              
//   ======================================

    function balanceOf (address account) public view override returns (uint256) {
        return Inventory.balanceOf (account);
    }
//   ======================================
//          BEGIN Function _transfer   
//   ======================================

    function _transfer ( address sender, address recipient, uint256 amount ) internal override whenNotPaused {
        require(!Inventory.Basis[sender].isLocked && 
               (!Inventory.Basis[recipient].isLocked || recipient == dividendReserves), "Address locked");
          
        require(amount > 0 && balanceOf(sender) >= amount, "Insufficient balance"); 
    
        if (Inventory.Basis[sender].accType != Internal  || sender == liquidityPair || recipient == liquidityPair) {
            require(amount <= _maxTokensPerTx, "Amount exceeds limit"); 
        }

        if (Inventory.Basis[recipient].accType != Internal )  {
            require( balanceOf(recipient) + amount <= _maxWalletBalance, "Exceeds limit");
        }      

        //  Indicates that all fees should be deducted from transfer
        bool applyFee = (Inventory.Basis[sender].isTaxFree || Inventory.Basis[recipient].isTaxFree) ? false:true;

        if (autoLiquidity && !ILiquidityVault(liquidityVault).isAddingLiquidity()) {_beforeTokenTransfer(sender, recipient, amount);}

        _tokenTransfer(sender, recipient, amount, applyFee); 
  
    }
//   ==========================================
//     BEGIN Function  __beforeTokenTransfer     
//   ==========================================

    function _beforeTokenTransfer (address sender, address recipient, uint256 amount) internal { 
        uint256 _newTokenPrice = getTokenPrice();

        if (_newTokenPrice == 0) {return;}

        if (isAdjustable) {
            uint256 _attenuationPoint =  Inventory.updateStack(liquidityPair, _newTokenPrice);

            Inventory.tradingTrack.lastTokenPrice = _newTokenPrice;
            Inventory.tradingTrack.lastTxnValue   = amount;

            if (Inventory.tradingTrack.needAttenuation && sender != liquidityPair)  {_attenuateImpulse(_attenuationPoint);}
            else if (sender    == liquidityPair)                {Inventory.tradingTrack.lastTxnType = 1;}
            else if (recipient == liquidityPair)                {Inventory.tradingTrack.lastTxnType = 2;}
            else                                                {Inventory.tradingTrack.lastTxnType = 0;}

            return;
        }

        if (sender != liquidityPair && Inventory.Basis[address(this)].balance >= _liquidityThreshold) { 
            _increaseLiquidity(_liquidityThreshold, true);
        }
    }
//   ======================================
//      BEGIN Function _tokenTransfer                   
//   ======================================

//   This Function is responsible for taking all fees, if 'applyFee' is true
    function _tokenTransfer (address sender, address recipient, uint256 tAmount, bool applyFee) internal override {

        BonusInfo  memory bonus;
        AmountInfo memory amount;

        uint256 transferAmount;
        uint256 totalFees;
        uint256 deflatFee;
        uint256 WicksellReservesFee;
        uint256 loyaltyRewardsFee;
        uint256 dynamicFee;

        // Calculate the Outflow values distribution (Raw Balance and Bonus)

        bonus.Balance  = Inventory.getBonus(sender);
        bonus.Outflow  = bonus.Balance > 0 ? (bonus.Balance * tAmount) / balanceOf(sender) : 0;
        amount.Outflow = tAmount - bonus.Outflow;

        // Collect all Fees and Bonus 

        if (applyFee) {
            if (sender == liquidityPair) {
               totalFees = _collectFees (tAmount, 0, 0, 0, 0, 0, bonusFee, projectFee); 
            } else if (recipient == liquidityPair) {
                    uint16  salesBonusFee = (Inventory.Basis[goldenBonus].balance == bonus.Balance)? 0 : reducedBonusFee;
                    dynamicFee = Inventory.calcDynamicFee(sender, tAmount, efficiencyFactor);

                    if (Inventory.isBurnable) {
                        loyaltyRewardsFee     = dynamicFee < (2 * minDynamicFee) ? dynamicFee : (2 * minDynamicFee);
                        dynamicFee           -= loyaltyRewardsFee;
                        deflatFee             = dynamicFee / 3;
                        WicksellReservesFee   = dynamicFee - deflatFee;
                    } else {loyaltyRewardsFee = dynamicFee;}

                    totalFees = _collectFees (tAmount, liquidityFee, deflatFee, WicksellReservesFee, loyaltyRewardsFee,
                                           contingencyFee, salesBonusFee, reducedProjectFee); 
            } else {
                    totalFees = _collectFees (tAmount, reducedLiquidityFee, 0, 0, minDynamicFee,
                                           contingencyFee, reducedBonusFee, reducedProjectFee); 
            }
         }

        transferAmount = tAmount - totalFees;

        // Calculate the Inflow values distribution (Raw Balance and Bonus)
        (bonus.Inflow, amount.Inflow) = (Inventory.Basis[recipient].isNonBonus) ? (0, transferAmount) : Inventory.shareAmount(transferAmount);

       // Update of sender and recipient balances 
        if (!Inventory.Basis[recipient].isLocked) {setNextMilestone(recipient, amount.Inflow);}

        Inventory.Basis[sender].balance    -= amount.Outflow;
        Inventory.Basis[recipient].balance += amount.Inflow;

         // Update the Bonus Shares 
        Inventory.Basis[goldenBonus].balance =  Inventory.Basis[goldenBonus].balance + bonus.Inflow - bonus.Outflow; 

        emit Transfer(sender, recipient, tAmount);
    }
//   ======================================
//     BEGIN Function  _collectFees     
//   ======================================
    function _collectFees (uint256 _tAmount, uint256 _liquidityFee, 
                        uint256 _deflatFee, uint256 _wicksellFee, 
                        uint256 _loyaltyRewardsFee, uint256 _contingencyFee, 
                        uint256 _bonusFee, uint256 _projectFee) private returns (uint256 totalFees) {
       
        return Inventory.collectFees(_tAmount, _liquidityFee, _deflatFee, _wicksellFee, 
                         _loyaltyRewardsFee, _contingencyFee, _bonusFee,  _projectFee,
                          address(this), contingencyFundsVault, projectFundsVault);                    
    }
//   ======================================
//               RFI Functions                  
//   ======================================

    function isTaxFree (address account) external view returns(bool) {
        return Inventory.Basis[account].isTaxFree;
    }

    function isExcludedFromBonus (address account) external view returns (bool) {
        return Inventory.Basis[account].isNonBonus;
    }
        
    function DeviationAnalysis() external view returns (bool LiquidityReady, bool AttenuationNeeded, bool WicksellReady, bool AllowBurn, bool AutoLiquidityOn) {
        LiquidityReady   = Inventory.Basis[address(this)].balance >= _liquidityThreshold;
        AttenuationNeeded =  Inventory.tradingTrack.needAttenuation;
        AllowBurn         =  Inventory.isBurnable;
        AutoLiquidityOn   =  autoLiquidity;
        WicksellReady     = (Inventory.Basis[wicksellReserves].balance > 0 && 
                             Inventory.Basis[wicksellReserves].lastTxn + 30 days < block.timestamp);
    }
//   ======================================
//             Support  Functions                  
//   ======================================
    function _attenuateImpulse (uint256 numTokensToLiquidity) private {

        Inventory.tradingTrack.buyingStack -= numTokensToLiquidity;
        numTokensToLiquidity               *= 2;

        if (Inventory.Basis[regulatoryFunds].balance >= numTokensToLiquidity) {
            _directTransfer(regulatoryFunds, address(this), numTokensToLiquidity);
            _increaseLiquidity(numTokensToLiquidity, true);
            Inventory.tradingTrack.lastTxnType        = 5;
            Inventory.tradingTrack.needAttenuation    = false;
        }
        else {
            _directTransfer(regulatoryFunds, address(this), Inventory.Basis[regulatoryFunds].balance);
            delete Inventory.Basis[regulatoryFunds];
            delete Inventory.tradingTrack;
            isAdjustable  = false;
        }
    }
//   ======================================
//            Manageable Functions                    
//   ======================================

    function shareCorporateAssets (address _beneficiary, uint256 _amountToShare) external  onlyRole(Contract_Manager) {
        require(Inventory.Basis[_beneficiary].accType == Contributor || 
                Inventory.Basis[_beneficiary].accType == Partner, "Invalid Account");
        
        uint64 _freezeDuration;       
        if      (Inventory.Basis[_beneficiary].accType == Contributor) { _freezeDuration =  550; }
        else if (Inventory.Basis[_beneficiary].accType == Partner)     { _freezeDuration = 1095; } 

        Inventory.sendAndFreeze(corporateAssets, _beneficiary, _amountToShare, _freezeDuration); 
    }

    function shareDividends () external onlyRole(Financial_Controller) { 
        require(Inventory.Basis[dividendReserves].balance > 0,"Zero balance") ;
        Inventory.shareDividends ();
    }

    function setUnfitAccount (address _unfitTrader) external onlyRole(Financial_Controller) {  
        Inventory.setUnfitAccount (_msgSender(),_unfitTrader);
    }

    function FisherAttenuation () external onlyRole(Treasury_Analyst) {
        uint256 _newTokenPrice = getTokenPrice();
        uint256 _attenuationPoint = Inventory.updateStack(liquidityPair, _newTokenPrice);
        require (Inventory.tradingTrack.needAttenuation, "Not allowed now");
        _attenuateImpulse(_attenuationPoint);
    }

    function excludeFromBonus (address account) external onlyRole(Treasury_Analyst) {
        Inventory.excludeFromBonus(_msgSender(), account);
    }
    
    function includeInBonus (address account) external onlyRole(Compliance_Auditor) {
        require(Inventory.Basis[account].accType != Internal, "Cannot receive bonus");
        Inventory.includeInBonus(_msgSender(), account);
    }

    function setTaxable (address account, bool status) external onlyRole(Compliance_Auditor) {
        require (Inventory.Basis[account].accType != Internal,"Cannot be modified");
        Inventory.Basis[account].isTaxFree = status;
        emit SetTaxableStatus (_msgSender(), account, status);
    }
    
    function salesClearance () external onlyRole(Distributor_Agent) {

        uint256 clearanceAmount = Inventory.Basis[authorizedDealer].balance;
        uint256 rewardsAmount   = Inventory.Basis[loyaltyRewards].balance / 10;
        rewardsAmount           = (rewardsAmount > clearanceAmount ? clearanceAmount : rewardsAmount);
        uint256 wicksellAmount  = clearanceAmount - rewardsAmount;

        _directTransfer(authorizedDealer, loyaltyRewards,   rewardsAmount);
        _directTransfer(authorizedDealer, wicksellReserves, wicksellAmount);
        
        authorizedDealer = address(0);
        
        if (Inventory.tokensSupply - Inventory.Basis[wicksellReserves].balance <= _minimumSupply ) {
            Inventory.isBurnable = false;
        }
    }
 
//   ======================================
//      Ownable Functions  (OVERRIDE)             
//   ======================================

    function transferOwnership (address newOwner) public virtual override onlyOwner {
        require(!Inventory.Basis[newOwner].isLocked && Inventory.Basis[newOwner].balance == 0, "Not allowed");
        
        address oldOwner = owner();
        _transferOwnership(newOwner);
        Inventory.Basis[oldOwner].accType = Ordinary;
        Inventory.setInternalStatus (newOwner, false);
    } 
//   ======================================
//          INVESTOR Functions                   
//   ======================================
    function InvestorBurn (uint256 burnAmount) external { 
        Inventory.investorBurn (_msgSender(), burnAmount);
     } 

    function ClaimLoyaltyRewards () external { 
        Inventory.claimLoyaltyRewards (_msgSender());
    }

    function LoyaltyRewardsAvailable (address account) external view returns (uint256 availableRewards) { 
     
        if (Inventory.Basis[account].isNonBonus || Inventory.Basis[account].isLocked || 
            Inventory.Basis[account].isUnrewardable || Inventory.Basis[account].nextMilestone > block.timestamp) {return 0;} 

        availableRewards = (Inventory.getBonus(account) * Inventory.Basis[loyaltyRewards].balance) / Inventory.Basis[goldenBonus].balance;
     }

    function SendAndFreeze (address _recipient, uint256 _amountToFreeze, uint64 _freezeDuration) external {
        if (!hasRole(Distributor_Agent, _msgSender())) { require(_freezeDuration >= 180, "Freeze duration invalid"); }
        require(_freezeDuration <= 1095, "Freeze duration invalid");
        require(Inventory.Basis[_recipient].accType != Partner, "Recipient not allowed");
        Inventory.sendAndFreeze (_msgSender(), _recipient, _amountToFreeze, _freezeDuration);                                                                                               
    }

    function ReleaseFutureAssets () external {
        Inventory.releaseFutureAssets (_msgSender());
    }

    function FutureAssetsBalance (address _recipient) external view returns (uint256 _unfrozenAmount, uint256 _frozenAmount, uint256 _futureBonus) {
        return Inventory.futureAssetsBalance (_recipient);
    } 

    function FutureAssetsNextRelease (address _recipient) external view returns (uint48 _daysToRelease, uint256 _valueToRelease) {
        uint48 _nextRelease = Inventory.Basis[_recipient].headFutureAssets * 86400;
        require (_nextRelease > 0, "Zero frozen assets" ); 
        require (block.timestamp < _nextRelease, "Already have assets released"); 
        
        _daysToRelease  = uint48((_nextRelease - block.timestamp) / 86400);
        _valueToRelease = (Inventory.futureAssets[_recipient][Inventory.Basis[_recipient].headFutureAssets].balance) / (10 ** _decimals);
    }

}
//**********************************//
//     S Y M P L E X I A  CONTRACT
//**********************************//

contract SymplexiaToken is Taxable {

   function initialize (string  memory _tokenName, 
			            string  memory _tokenSymbol,
			            address _projectFundsVault, 
			            address _contingencyFundsVault ) public initializer {

        _BaseToken_init (_tokenName, _tokenSymbol, _projectFundsVault, _contingencyFundsVault);
        _Adjustable_init ();
        _Taxable_init (); 
    }   

}
