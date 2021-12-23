pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tournir {

    event LogRegisterOInRoom(uint256 roomNumber, address teamO);
    event LogRegisterPInRoom(uint256 roomNumber, address teamO);
    event LogRegisterJInRoom(uint256 roomNumber, address teamO);
    event LogClearRoom(uint256 roomNumber);
    event LogNewRoomRegistered(uint256 roomNumber);
    event LogRoomDeleted(uint256 roomNumber);
    event LogContributionPayed(address member);
    event LogWithdrawn(uint256 balance);
    event LogWinningPayed(address member, uint256 balance);

    address public owner;
    address public paymentToken;
    uint256 public memberContribution;

    modifier onlyOwner(){
        require(msg.sender==owner, "ERROR::AUTH");
        _;
    }

    struct Room{
        bool available;
        address teamP;
        address teamO;
        address judge;
    }

    //hashtable
    mapping(uint256=>Room) public rooms;

    constructor(
        address owner_,
        address paymentToken_,
        uint256 memberContribution_
    ){
        owner=owner_;
        paymentToken=paymentToken_;
        memberContribution=memberContribution_;
    }

    function registerRoom(uint256 roomNumber_) external onlyOwner{
        require(roomNumber_>0 &&rooms[roomNumber_].available==false, "ERROR::ALREADY_AVAILABLE");
        rooms[roomNumber_].available = true;
        emit LogNewRoomRegistered(roomNumber_);
    }

    function bookRoom(uint256 roomNumber_, address teamO, address teamP, address judge) external onlyOwner{
        require(roomNumber_>0 &&rooms[roomNumber_].available==true, "ERROR::ALREADY_BOOKED");
        require(rooms[roomNumber_].teamP!=address(0) && rooms[roomNumber_].teamO!=address(0) && rooms[roomNumber_].judge!=address(0),"ERROR::INVALID_MEMBERS");

        rooms[roomNumber_].available = false;

        rooms[roomNumber_].teamO=teamO;
        emit LogRegisterOInRoom(roomNumber_, teamO);
        rooms[roomNumber_].teamP=teamP;
        emit LogRegisterPInRoom(roomNumber_, teamP);
        rooms[roomNumber_].judge=judge;
        emit LogRegisterJInRoom(roomNumber_, judge);
    }

    function unbookRoom(uint256 roomNumber_) external onlyOwner{
        require(roomNumber_>0 &&rooms[roomNumber_].available==false, "ERROR::ALREADY_AVAILABLE");

        rooms[roomNumber_].available = true;

        rooms[roomNumber_].teamO=address(0);
        rooms[roomNumber_].teamP=address(0);
        rooms[roomNumber_].judge=address(0);

        emit LogClearRoom(roomNumber_);
    }

    function deleteRoom(uint256 roomNumber_) external onlyOwner {
        require(
            rooms[roomNumber_].available == true,
            "ERROR::INVALID_ACTION"
        );

        delete rooms[roomNumber_];

        emit LogRoomDeleted(roomNumber_);
    }

    function payWinning(address member) external onlyOwner {
        require(
            member != address(0),
            "ERROR::INVALID_MEMBER"
        );

        uint256 balance = IERC20(paymentToken).balanceOf(address(this))/10;
        IERC20(paymentToken).transferFrom(address(this), member, balance);
        emit LogWinningPayed(member, balance);
    }

    function payContribution() external{
        IERC20(paymentToken).transferFrom(msg.sender, address(this),memberContribution);

        emit LogContributionPayed(msg.sender);
    }

    function withdraw() external onlyOwner {
        uint256 balance = IERC20(paymentToken).balanceOf(address(this));
        IERC20(paymentToken).transferFrom(address(this), owner, balance);
        emit LogWithdrawn(balance);
    }

}
