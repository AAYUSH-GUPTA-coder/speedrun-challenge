// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping (address => uint) public balances;
  uint256 public constant threshold = 1 ether;
  event Stake(address,uint256);
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    //   deadline = block.timestamp + 120 seconds;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() payable public {
       if(balances[msg.sender] == 0){
            balances[msg.sender] = msg.value;
        } else{
            balances[msg.sender] += msg.value;
        }
      emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public {
    require(block.timestamp > deadline, "time remaining");
    if(address(this).balance  >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
      console.log("done");
    }else{
      openForWithdraw = true;
      console.log("true");
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public {
      require(openForWithdraw == true, "openForWithdraw is false");
        uint amount = balances[msg.sender];
        (bool sent, ) =  msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256){
    if(deadline > block.timestamp){
       return deadline - block.timestamp;
    }
    else{
      return 0;
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
      stake();
  }

}
