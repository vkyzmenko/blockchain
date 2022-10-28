pragma solidity >=0.5.0 < 0.9.0;

contract Ballot{
    uint OwnerFee;
    uint VoteFinish;
    uint Payment;
    
    address public Owner;
    constructor(){
        Owner = msg.sender;
    }
    
    address[] public CandidateList;
    
    mapping(address => bool) VotedFlag;
    mapping(address => uint) VotedCandidateNum;
    mapping(address => uint) VoteCount;
    
    struct Info{
        uint TimeLeft;
        uint paymentAmount;
        uint Fee;
        address[] Candidates;
        mapping(address => uint) VotesCount;
    }
   
    //createVoting
    function createVoting(uint Duration, uint _OwnerFee, uint _Payment, address[] memory _CandidateList) public{
        require(msg.sender == Owner, "You are not the Owner!");
        VoteFinish = block.timestamp + Duration * 86400;
        OwnerFee = _OwnerFee;
        Payment = _Payment;
        
        for(uint i = 0; i < _CandidateList.length; i++){
            CandidateList.push(payable(_CandidateList[i]));
            VoteCount[CandidateList[i]] = 0;
        }
    }
    
    //WithdrawFees
    function WithdrawFees() public{
        require(msg.sender == Owner, "You are not the Owner!");
        uint VotesToWin = 0;
        uint Votes = 0;
        uint WinnerCount = 0;
        
        for(uint i = 0; i < CandidateList.length; i++){
            if(VoteCount[CandidateList[i]] == VotesToWin){
                WinnerCount += 1;
            }
            if(VoteCount[CandidateList[i]] > VotesToWin){
                VotesToWin = VoteCount[CandidateList[i]];
                Votes += VoteCount[CandidateList[i]];
                WinnerCount = 1;
            }
            Votes += VoteCount[CandidateList[i]];
        }
        
        WinAmount = (1 - OwnerFee) * Payment * Votes/ WinnerCount;
        
        if(WinAmount > 0){
            for(uint i = 0; i < CandidateList.length; i++){
                if(VoteCount[CandidateList[i]] == VotesToWin){
                    CandidateList[i].transfer(WinAmount);
                }
            }
        }
        payable(Owner).transfer(OwnerFee * Payment * Votes);
    }
    
    //VoteFor
    function voteFor(uint CandidateNum) public payable{
        require(block.timestamp < VoteFinish, "Voting is over");
        require(!VotedFlag[msg.sender], "You have already voted");
        require(msg.value == Payment, "Wrong amount");
        
        VotedCandidateNum[msg.sender] = CandidateNum;
        VotedFlag[msg.sender] = true;
        
        VoteCount[CandidateList[CandidateNum]] += 1;
    }
    
    function getVoteInfo() public returns(Info memory VoteInfo){
        VoteInfo = Info({
            TimeLeft: VoteFinish - block.timestamp,
            paymentAmount: Payment,
            Fee: OwnerFee,
            Candidates: CandidateList,
            VotesCount: VoteCount
        })
    }
}