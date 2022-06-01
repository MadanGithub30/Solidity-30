//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract EcommereceAmaz{
    
    struct Product{ // creating Product of type struct.
      string title;
      string desc;
      address payable seller;
      uint productId;
      uint price;
      address buyer;
      bool delivered;
    }     
    uint counter = 1;
    Product[] public products;// creating an array to store all the info of the Product for the particular id of variable products.
    address payable public manager;

    bool destroyed = false;

    modifier isNotDestroyed{
        require(!destroyed,"Contract does not exist");
        _;
    }

    constructor(){
        manager = payable(msg.sender);//Initiallizing the manager with the manager address.
    }

    event registered(string title,uint productId,address seller);
    event bought(uint productId,address buyer);
    event delivered(uint productId);


    function registerProduct(string memory _title,string memory _desc,uint _price) public isNotDestroyed {
        require(_price>0,"Price should be greater than zero");
        Product memory tempProduct; //creating tempProduct variable of type Product.
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * 10**18;// OR 10**18.
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);// Pushing all the elements to array products.
        counter++;
        emit registered(_title,tempProduct.productId,msg.sender);

    } 

    function buy(uint _productId) payable public isNotDestroyed{
        require(products[_productId-1].price==msg.value,"Please pay the exact price");//Here checking The seller registered price for the product is equal to price paying by the buyer.
        require(products[_productId-1].seller!=msg.sender,"Seller can't be the buyer");
        products[_productId-1].buyer=msg.sender;
        emit bought(_productId,msg.sender);


    }

    function delivery(uint _productId) public isNotDestroyed{
        require(products[_productId-1].buyer==msg.sender,"Only buyer can confirm");
        products[_productId-1].delivered = true;
        products[_productId-1].seller.transfer(products[_productId-1].price);//Here from the registered price in registerProduct is transfereing to the seller.
        emit delivered(_productId);
    }

    // function destroy() public{
    //     require(msg.sender==manager,"Only manager can call the function");
    //     selfdestruct(manager);//Solidity provides a novel "selfdestruct" (globally  function). By calling this selfdestruct function, a smart contract can be removed from the blockchain
    // }

    function destroy() public isNotDestroyed{
        require(manager==msg.sender);// if the detsoy function is called by the manager then will move to next step.
        manager.transfer(address(this).balance);//Transfering whatever there in contract to manager and manager will transfer the amount to buyer.
        destroyed=true;

    }
    //If non of the function is works then the fallback function works
    fallback() payable external{                                
        payable(msg.sender).transfer(msg.value); //Transfereing the amount back to sender. 
    }

}