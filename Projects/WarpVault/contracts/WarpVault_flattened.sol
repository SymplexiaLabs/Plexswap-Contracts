
// File: Projects/WarpVault/contracts/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: Projects/WarpVault/contracts/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: Projects/WarpVault/contracts/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.1;

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

// File: Projects/WarpVault/contracts/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: Projects/WarpVault/contracts/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: Projects/WarpVault/contracts/BasicAccessControl.sol



pragma solidity ^0.8.0;


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
         require(account == _msgSender(), "AccessControl: can only renounce roles for self");
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

// File: Projects/WarpVault/contracts/WarpVault.sol


//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;





//    Interfaces   



//**********************************//
//    W  A  R  P  V  A  U  L  T  
//**********************************//
contract WarpVault is BasicAccessControl {
    using SafeERC20 for IERC20;

    struct TokenInfo {
           uint256 targetBalance;
           bool    isLimitUnlocked;
           bool    isInitialized;
    }

    mapping (address => TokenInfo) internal vaultMapping;

    address public   beneficiary;
    address public   contractManager;
    bool    public   immutable isMutable;

    uint8 constant Contract_Manager     = 1;
    uint8 constant Financial_Controller = 11;
    uint8 constant Compliance_Auditor   = 12;

    event BalanceLimitUpdated   (address authorizer, uint256 targetBalance);
    event BeneficiaryUpdated    (address authorizer, address beneficiary);
    event VaultReservesReleased (address authorizer, address token, address beneficiary, uint256 _releasedValue);
    event CoinBalanceReleased   (address authorizer, address beneficiary, uint256 _releasedValue);
    event Tokeninitialized      (address _token, uint256 _targetBalance, bool _isLimitUnlocked );

    constructor (address _manager, address _beneficiary, bool _isMutable)  {
        contractManager = _manager;
        beneficiary     = _beneficiary;
        isMutable       = _isMutable;

        _setupRole(Contract_Manager,     contractManager);
        _setupRole(Financial_Controller, contractManager);
        _setupRole(Compliance_Auditor,   contractManager);

        _setRoleAdmin(Contract_Manager,     Contract_Manager);
        _setRoleAdmin(Financial_Controller, Contract_Manager);
        _setRoleAdmin(Compliance_Auditor,   Contract_Manager);
    }

    function initializeToken(address _token, uint256 _targetBalance, bool _isLimitUnlocked ) external onlyRole(Financial_Controller) {
        require (!vaultMapping[_token].isInitialized, "Token already initialized");
        require (_targetBalance > 0, "Limit invalid");
        vaultMapping[_token].targetBalance      = _targetBalance * (10**IERC20Metadata(_token).decimals());
        vaultMapping[_token].isLimitUnlocked    = _isLimitUnlocked;
        vaultMapping[_token].isInitialized      = true;
        emit Tokeninitialized (_token, _targetBalance, _isLimitUnlocked );
    }

    function changeBeneficiary (address _newBeneficiary) external onlyRole(Compliance_Auditor) {
        require (isMutable, "This contract is immutable.");
        require (hasRole(Financial_Controller, _newBeneficiary),"Beneficiary without the needed role");
        beneficiary = _newBeneficiary;
        emit BeneficiaryUpdated (_msgSender(), beneficiary);
    }

    function changeBalanceLimit (address _token, uint256 _targetBalance) external onlyRole(Compliance_Auditor)  {
        require (isMutable, "This contract is immutable.");
        require (vaultMapping[_token].isInitialized, "Token is not initialized");
        require (_targetBalance > 0, "Limit invalid");
        vaultMapping[_token].targetBalance      = _targetBalance * (10**IERC20Metadata(_token).decimals());
        emit BalanceLimitUpdated (_msgSender(), _targetBalance );
    }

    function setLimitUnlocked (address _token, bool _newStatus) external onlyRole(Financial_Controller) {
        require (vaultMapping[_token].isInitialized, "Token is not initialized");
        vaultMapping[_token].isLimitUnlocked = _newStatus;
    }

    function tokenParams (address _token) external view returns (uint256, bool) {
        require (vaultMapping[_token].isInitialized, "Token is not initialized");        
        return  (vaultMapping[_token].targetBalance / (10**IERC20Metadata(_token).decimals()), vaultMapping[_token].isLimitUnlocked );  
    }
    
    function releaseVaultReserves(address _token) external onlyRole(Financial_Controller) {
        require (vaultMapping[_token].isInitialized, "Token is not initialized");
        uint256 _balanceVault = IERC20(_token).balanceOf(address(this));
        uint256 _releaseValue;
        if (vaultMapping[_token].isLimitUnlocked) {
            uint256 minBalance = vaultMapping[_token].targetBalance / 5;
            require(_balanceVault >= minBalance, "Vault Reserves below limit");
            _releaseValue = (_balanceVault * _balanceVault) / vaultMapping[_token].targetBalance;
            _releaseValue = (_releaseValue > _balanceVault) ?  _balanceVault : _releaseValue;
        } else {
            require(_balanceVault >= vaultMapping[_token].targetBalance, "Vault Reserves below limit");
            _releaseValue = vaultMapping[_token].targetBalance;
        }
        IERC20(_token).safeTransfer(beneficiary, _releaseValue);
        emit VaultReservesReleased (_msgSender(), address(_token), beneficiary, _releaseValue);
    }

    function releaseCoinBalance () external onlyRole(Financial_Controller) {
        uint256 amountToRelease = address(this).balance;
        require(amountToRelease > 0, "The Balance must be greater than 0");

        payable(beneficiary).transfer(amountToRelease);
        emit CoinBalanceReleased (_msgSender(), beneficiary, amountToRelease);
    }

}

