// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721 {
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function walletOfOwner(address owner) external view returns (uint256[] memory);
}
 contract MyContract {
struct Payment {
    uint256 id;
    uint256 boostAmount;
    address owner;
    uint256 counter;
}

// mapping(address => Payment) public accountPayments;
mapping(address => mapping(uint256 => Payment)) public accountPayments;
 uint256[] public paymentIds;
 Payment[] public payments;
    // Payment[] private payments;
     ERC721 public nftContract;
     constructor(address _nftContract){
            nftContract = ERC721(_nftContract);
   }
   
    function payAmount(uint256 accountId, uint256 boostAmount) external payable {
    // require(msg.value > 0, "Amount not sent");
    require(msg.value == boostAmount, "Incorrect boost amount");
    uint256[] memory ids = ERC721(nftContract).walletOfOwner(msg.sender);
    bool found = false;
    for (uint256 i = 0; i < ids.length; i++) {
        if (ids[i] == accountId) {
            found = true;
            break;
        }
    }
    require(found, "ID not found");

    Payment storage payment = accountPayments[msg.sender][accountId];
    payment.id = accountId;
    payment.boostAmount += boostAmount;
    payment.owner = msg.sender;
    payment.counter++;
    
    Payment memory newPayment = Payment(accountId, boostAmount, msg.sender, payment.counter);
    payments.push(newPayment);
    // paymentIds.push(newPayment);
}

function boosterDetail(address _address) external view returns (uint256[] memory, uint256[] memory) {
    uint256 count = 0;

    // Count the number of matching payments
    for (uint256 i = 0; i < payments.length; i++) {
        if (payments[i].owner == _address) {
            count++;
        }
    }
    // Create arrays to store the results
    uint256[] memory tokenIds = new uint256[](count);
    uint256[] memory boostAmounts = new uint256[](count);

    // Retrieve the matching payments
    uint256 currentIndex = 0;
    for (uint256 i = 0; i < payments.length; i++) {
        if (payments[i].owner == _address) {
            tokenIds[currentIndex] = payments[i].id;
            boostAmounts[currentIndex] = payments[i].boostAmount;
            currentIndex++;
        }
    }

    return (tokenIds, boostAmounts);
}
//BHAI Usman code give
// function boosterDetail(address _address) external view returns(uint256[] memory, uint256[] memory){
//     Payment[] memory filteredSales = new Payment[](payments.length);
//         uint256 count = 0;
//         for (uint256 i = 0; i < payments.length; i++) {
//             if (payments[i].owner == _address) {
//                 filteredSales[count] = payments[i];
//                 count++;
//             }
//         }

//         // Create a new array with the exact length of filtered sales
//         // Payment[] memory finalSales = new Payment[](count);
//          uint256[] memory boostAmounts = new uint256[](count);
//          uint256[] memory tokenIds = new uint256[](count);
        
//         for (uint256 i = 0; i < count; i++) {
//             // finalSales[i] = filteredSales[i];
//             tokenIds[i] = filteredSales[i].id;
//             // boostAmounts[i] = filteredSales[i].boostAmount;

//         }
//             //  return finalSales; 
//         return (tokenIds,boostAmounts);

//  }

function withdrawBNB(address payable recipient) external  {
    require(address(this).balance > 0 , "Insufficient contract balance");
    recipient.transfer(address(this).balance);
}
// function boosterDetail(address _address) external view returns (uint256[] memory, uint256[] memory) {
//     uint256[] memory ids = new uint256[](payments.length);
//     uint256[] memory boostAmounts = new uint256[](payments.length);
//     uint256 count = 0;

//     for (uint256 i = 0; i < payments.length; i++) {
//         if (payments[i].owner == _address) {
//             ids[count] = payments[i].id;
//             boostAmounts[count] = payments[i].boostAmount;
//             count++;
//         }
//     }

//     // Trim the arrays to the correct size
//     assembly {
//         mstore(ids, count)
//         mstore(boostAmounts, count)
//     }

//     return (ids, boostAmounts);
// }



// function checkDetails(address user)
//     public
//     view
//     returns (uint256[] memory, uint256[] memory)
// {
//     uint256[] memory Ids = new uint256[](paymentIds.length);
//     uint256[] memory boostAmounts = new uint256[](paymentIds.length);

//     for (uint256 i = 0; i < paymentIds.length; i++) {
//         uint256 tokenId = nftContract.tokenOfOwnerByIndex(user, i);
//         Payment storage payment = accountPayments[user][tokenId];

//         Ids[i] = payment.id;
//         boostAmounts[i] = payment.boostAmount;
//     }

//     return (paymentIds, boostAmounts);
// }

}