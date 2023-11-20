// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.4;

import "./ITRC20.sol";
import "./TRC20.sol";
import "./AccessControl.sol";
import "./ReentrancyGuard.sol";
import "./ISunswapV2router02.sol";

contract RampService is AccessControl, ReentrancyGuard {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPERADMIN_ROLE");

    /// @notice A record of signers
    mapping(address => bool) public signers;
    /// @notice A record of supported assets
    mapping(address => bool) public supportedAssets;
    /// @notice A record of address book
    mapping(address => bool) public addressBook;

    mapping(string => mapping(address => uint256)) public buyTx;

    mapping(string => mapping(address => uint256)) public sellTx;

    mapping(string => mapping(address => uint256)) public swapTx;

    event Sold(address token, uint256 amount, address receiver, string txid);
    event Purchased(address token, uint256 amount, string txid);
    event SwapAndSold(address token, uint256 amount, uint256[] amounts, address receiver, string txid);

    bool public serviceActive;
    bytes32 public domainSeparator;


    constructor() {
        bytes32 ChainId;
        assembly {
            ChainId := chainid()
        }
        domainSeparator = keccak256(
            abi.encode(
                keccak256(bytes("ChainVerse|RampService")),
                ChainId,
                address(this)
            )
        );
        serviceActive = true;
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
        _setRoleAdmin(ADMIN_ROLE, OWNER_ROLE);

        _grantRole(OWNER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(SUPER_ADMIN_ROLE,msg.sender);
        //solhint-disable-next-line no-inline-assembl
    }

    modifier isActive() {
        require(serviceActive, "RampService: Service is off");
        _;
    }

    function updateService() external {
        serviceActive = !serviceActive;
    }

    function updateAsset(address asset) public {
        supportedAssets[asset] = !supportedAssets[asset];
    }

    function updateSigner(address signer) public {
        signers[signer] = !signers[signer];
    }

    function updateAddressBook(address _address) public onlyRole(SUPER_ADMIN_ROLE) {
		addressBook[_address] = !addressBook[_address];
	}

    function updateSuperAdminRole(address multiwallet) public onlyRole(SUPER_ADMIN_ROLE){
        _setupRole(SUPER_ADMIN_ROLE,multiwallet);
    }

    function buy(
        address payable receiver,
        address token,
        uint256 amount,
        string memory txId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant isActive {
        require(supportedAssets[token], "RampService: asset is not supported");
        require(buyTx[txId][token] == 0, "RampService: txId is existed");

        bytes32 _hashedMessage = keccak256(
            abi.encodePacked(domainSeparator, receiver, token, amount, txId)
        );
        address signatory = ecrecover(_hashedMessage, v, r, s);
        require(
            signatory != address(0) && signers[signatory],
            "RampService: invalid signature"
        );
        if (token == address(0)) {
            require(
                address(this).balance >= amount,
                "RampService: asset is not enough"
            );
            receiver.transfer(amount);
        } else {
            require(
                ITRC20(token).balanceOf(address(this)) >= amount,
                "RampService: asset is not enough"
            );
            ITRC20(token).transfer(receiver, amount);
        }
        buyTx[txId][token] = amount;

        emit Sold(token, amount, receiver, txId);
    }

    function sell(
        address token,
        uint256 amount,
        string memory txId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable nonReentrant isActive {
        require(supportedAssets[token], "RampService: asset is not supported");
        require(sellTx[txId][token] == 0, "RampService: txId is existed");
        require(amount > 0, "RampService: amount is invalid");

        bytes32 _hashedMessage = keccak256(
            abi.encodePacked(domainSeparator, token, amount, txId)
        );
        address signatory = ecrecover(_hashedMessage, v, r, s);
        require(
            signatory != address(0) && signers[signatory],
            "RampService: invalid signature"
        );

        if (token == address(0)) {
            require(msg.value >= amount, "RampService: amount is wrong");
        } else {
            require(
                ITRC20(token).transferFrom(msg.sender, address(this), amount),
                "RampService: Failed Transferring"
            );
            // ITRC20(token).transfer(receiver, amount);
        }
        sellTx[txId][token] = amount;
        emit Purchased(token, amount, txId);
    }

    function forceTransfer(
        address token,
        uint256 amount,
        address payable receiver
    ) public onlyRole(SUPER_ADMIN_ROLE) returns (bool) {
        require(receiver != address(0), "RampService: invalid query");
        require(
            addressBook[receiver],
            "RampService: address not in addressBook"
        );

        bool sent = false;
        if (token == address(0)) {
            require(
                address(this).balance >= amount,
                "RampService: asset is not enough"
            );
            // solhint-disable-next-line avoid-low-level-calls
            receiver.transfer(amount);
            sent = true;
        } else {
            require(
                ITRC20(token).balanceOf(address(this)) >= amount,
                "RampService: Token is not enough"
            );
            ITRC20(token).transfer(receiver, amount);
            sent = true;
        }

        return sent;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    // address public router;

    // function setRoutrt(address router_) public {
    //     router = router_;
    // }

    function buyBySwap(
        address router,
        address receiver,
        address[] memory path,
        uint256 amount,
        uint256 minAmountOut,
        string memory txId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant isActive {
        require(supportedAssets[path[path.length - 1]], "RampService: asset is not supported");
        require(swapTx[txId][path[path.length - 1]] == 0, "RampService: txId is existed");

        bytes32 _hashedMessage = keccak256(
            abi.encodePacked(
                domainSeparator,
                receiver,
                path,
                amount,
                minAmountOut,
                txId 
            )
        );
        address signatory = ecrecover(_hashedMessage, v, r, s);

        require(
            signatory != address(0) && signers[signatory],
            "RampService: invalid signature"
        );

        uint256[] memory amounts;
        require(
            ITRC20(path[0]).approve(address(router), amount),
            "RampService: Failed approval"
        );
        if (path[path.length - 1] == v2(address(router)).WETH()) {
            amounts = v2(address(router)).swapExactTokensForETH(
                amount,
                minAmountOut,
                path,
                receiver,
                block.timestamp + 150000
            );
        } else {
            amounts = v2(address(router)).swapExactTokensForTokens(
                amount,
                minAmountOut,
                path,
                receiver,
                block.timestamp + 150000
            );
        }
        // require(sent, "RampService: Failed Processing");

        swapTx[txId][path[path.length - 1]] = amount;

        emit SwapAndSold(path[path.length - 1], amount, amounts, receiver, txId);
    }
}
