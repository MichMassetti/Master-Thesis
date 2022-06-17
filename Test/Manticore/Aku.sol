contract AkuAuction {
    address owner;
    uint256 public maxNFTs = 15000;
    uint256 y=0;
    uint256 public totalForAuction = 5495; //529 + 2527 + 6449
    bool flag;
    uint effective=1;
    struct bids {
        address bidder;
        uint256 price;
        uint8 finalProcess; //0: Not processed, 1: refunded, 2: withdrawn
    }

    uint256 public price;
   
    mapping(address => uint256) public personalBids;
    mapping(uint256 => bids) public allBids;
    uint256 fee;
    uint256 public bidIndex = 1;
    uint256 public totalBids;
    uint256 public refundProgress = 1;
    bool public claimedProject=false;
   
    constructor()
    {
        price=1000;
        owner=msg.sender;
        flag=true;
        fee=100;
    }


    receive() external payable {
        revert("Please use the bid function");
    }

    
    function bid_(uint8 amount)payable public {
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
            effective++;
            require(sent, "Failed to refund bidder");

          }
          refundProgress++;
        
        } 
        

    }

    

    function claimProjectFunds() external returns (bool v) {
        if(refundProgress == totalBids){
             
            flag=false;
        }
        
        return flag;
            
    }

    function crytic_test_flag() view public returns (bool){
        return flag;
    }
    

}