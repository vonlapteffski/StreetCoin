pragma solidity ^0.4.11;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
/*
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    } */
}

contract Alterium is owned {

    uint256 public sellPrice;
    uint256 public buyPrice;
    uint256 public totalSupply;
    uint8 public decimals;
    uint minBalanceForAccounts;
    string public name;
    string public symbol;

    event Transfer(address indexed from, address indexed to, uint256 amount);   //Transfer Event
    event FrozenFunds(address target, bool frozen);

    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;

    function Alterium(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) { //Constructor
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;          // All tokens to creator
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
    }

    function transfer(address _to, uint256 _amount) { // Transfer tokens

        require (balanceOf[msg.sender] >= _amount);      // Check if sender has enough
        require (balanceOf[_to] + _amount >= balanceOf[_to]);// Check for overflow
        require (!frozenAccount[msg.sender]);            // Check for
        require (!frozenAccount[_to]);                   // frozen accounts

        if (msg.sender.balance < minBalanceForAccounts)  // If sender has't enough ether to pay a fee
            sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);//??????????????????????????????
        balanceOf[msg.sender] -= _amount;               // Sending tokens
        balanceOf[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        balanceOf[owner] += 10;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal { // Private transfer function
        require (_to != 0x0);                            // Use burn() instead
        require (balanceOf[_from] >= _amount);           // Check if sender has enough
        require (balanceOf[_to] + _amount > balanceOf[_to]); // Oveflow check
        require (!frozenAccount[_from]);                 // Check for
        require (!frozenAccount[_to]);                   // frozen accounts

        balanceOf[_from] -= _amount;                     // Sending tokens
        balanceOf[_to] += _amount;
        Transfer(_from, _to, _amount);
    }

    function buy() payable returns (uint amount) {
        amount = msg.value / buyPrice;                   // Calculates the amount
        require (balanceOf[this] >= amount);             // Check if it has enough to sell

        balanceOf[msg.sender] += amount;                 // Adds to the buyer
        balanceOf[this] -= amount;                       // Substracts from the seller
        Transfer(this, msg.sender, amount);              // Event
        return amount;
    }

    function sell(uint amount) returns (uint revenue) {
        require (balanceOf[msg.sender] >= amount);       // Check if the sender has enough

        balanceOf[this] += amount;                       // Adds to contract balance
        balanceOf[msg.sender] -= amount;                 // Substracts from seller's balance
        revenue = amount * sellPrice;                    // Calculating revenue
        require (msg.sender.send(revenue));              // Sends ether to the seller: it's important to
                                                         // do this last to prevent recursion attacks
        Transfer(msg.sender, this, amount);
        return revenue;
    }

//-------------------------------------------------------------------------------------------------
// Admin methods
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);                // Events
        Transfer(owner, target, mintedAmount);           // Events
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function setMinBalance(uint minimumBalanceInFinney) onlyOwner {
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }
//-------------------------------------------------------------------------------------------------

    contract Publish {

        function Publish(address advertiser, address publisher, uint256 cost) {

        }


    }
}