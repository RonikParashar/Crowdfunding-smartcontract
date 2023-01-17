
pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{
  mapping(address=>uint) public contributors; // mapping to contributors telling us how much they are paying
  address public manager;
  uint public minimumContribution;
  uint public deadline;
  uint public target;
  uint public raisedAmount;
  uint public noOfContributors;


 struct Request{ // Manager requesting for donation and voting takes place 
    string description; // why does he need money
    address payable recipient; // address of person for whom we are asking the donation
    uint value; // how much to pay
    bool completed; //if voting is completed or not
    uint noOfVoters;
    mapping(address=>bool) voters; // contain the name of people who have voted
 }

 mapping(uint=>Request) public requests; // Mapping with index of diifrent kind of donations[ex- 1)Enviornment 2)Children .... ]
 uint public numRequest;
    
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp + _deadline; // for how much time the block will be alive
        minimumContribution = 100 wei;
        manager=msg.sender; // after deploying the value will be sent to manager
    }

    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has passed");  // checking if contract still exist
        require(msg.value >= minimumContribution,"Minimum Contribution is not met"); // checking if minimum contribution is done or not
         
         if(contributors[msg.sender]==0){
            noOfContributors++;
         }

         contributors[msg.sender]+=msg.value;
         raisedAmount+=msg.value;
    }

  function getContractBalance() public view returns(uint){
    return address(this).balance;
  }  

  function refund() public{
    require(block.timestamp > deadline && raisedAmount < target,"You are not eligible to refund"); // refunding user thier eth if in the given time the targrted amount is not met
    require(contributors[msg.sender]>0); // allowing only those user to refund that have donated in first place
    address payable user = payable(msg.sender); 
    user.transfer(contributors[msg.sender]);
    contributors[msg.sender]=0;
  }
 
 modifier onlyManager(){
    require(msg.sender==manager,"Only manager can call this function");
    _;
 }

 function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
    Request storage newRequest = requests[numRequest]; // in above we made mapping in struct so if we want to use this struct we need to use storage if we use memory we will get error
    numRequest++;
    newRequest.description = _description;
    newRequest.recipient = _recipient;
    newRequest.value = _value;
    newRequest.completed = false;
    newRequest.noOfVoters=0;
 }

 // creating a func to perform voting
 function voteRequest(uint _requestNo /*index for which request contribution is taking palce*/) public {
    require(contributors[msg.sender]>0,"You must be a contributor before voting");
    Request storage thisRequest=requests[_requestNo];
    require(thisRequest.voters[msg.sender]==false,"You have already voted");
    thisRequest.voters[msg.sender]=true; // changing it to true once a user has voted so if he votes again the above code condition of 'false' will not match 
    thisRequest.noOfVoters++;

 }
 function makePayment(uint _requestNo) public onlyManager{
    require(raisedAmount>=target);
    Request storage thisRequest=requests[_requestNo];
    require(thisRequest.completed==false,"The request has been completed");
    require(thisRequest.noOfVoters > noOfContributors/2); // checking if 50% of contributors are ready or not
    thisRequest.recipient.transfer(thisRequest.value);
    thisRequest.completed=true;
 }

 

}