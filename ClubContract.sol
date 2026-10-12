// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import "@openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol";

contract ClubPoints is ERC20Burnable, Ownable {
    constructor() ERC20("Club Points", "CPT") Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10 ** 18);
    }

    function mintPoints(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function distribute(address to, uint256 amount) external onlyOwner {
        _transfer(msg.sender, to, amount);
    }
}

contract CampusMemo is ERC721URIStorage, Ownable, ReentrancyGuard {
    ClubPoints public immutable points;
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant PRICE = 100 * 10 ** 18;
    uint256 public constant CHECK_IN_REWARD = 10 * 10 ** 18;
    uint256 public mintedCount;
    string public metadataURI;

    bool public checkInEnabled;
    mapping(address => uint256) public nextCheckIn;

    event MemoMinted(address indexed member, uint256 indexed tokenId);
    event CheckedIn(address indexed member, uint256 reward);
    event CheckInStatusChanged(bool enabled);

    constructor(address pointsAddress, string memory uri)
        ERC721("Campus-Memo", "CMEM") Ownable(msg.sender)
    {
        require(pointsAddress.code.length > 0, "Invalid CPT contract");
        require(bytes(uri).length > 0, "Empty URI");
        points = ClubPoints(pointsAddress);
        metadataURI = uri;
    }

    // Member first calls CPT.approve(this contract, PRICE).
    // burnFrom consumes that allowance and destroys 100 CPT.
    function mintMemo() external nonReentrant returns (uint256 tokenId) {
        require(mintedCount < MAX_SUPPLY, "Sold out");
        tokenId = ++mintedCount; // IDs 1..10; reverted if payment/mint fails.
        points.burnFrom(msg.sender, PRICE);
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, metadataURI);
        emit MemoMinted(msg.sender, tokenId);
    }

    function setCheckInEnabled(bool enabled) external onlyOwner {
        checkInEnabled = enabled;
        emit CheckInStatusChanged(enabled);
    }

    // Admin funds this contract using CPT.distribute before enabling claims.
    // Rewards transfer existing points; they do not mint new CPT.
    function dailyCheckIn() external nonReentrant {
        require(checkInEnabled, "Check-in disabled");
        require(block.timestamp >= nextCheckIn[msg.sender], "Wait 24 hours");
        require(points.balanceOf(address(this)) >= CHECK_IN_REWARD, "Reward pool empty");
        nextCheckIn[msg.sender] = block.timestamp + 1 days;
        require(points.transfer(msg.sender, CHECK_IN_REWARD), "Reward transfer failed");
        emit CheckedIn(msg.sender, CHECK_IN_REWARD);
    }
}
