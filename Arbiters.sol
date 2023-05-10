// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

contract Seller_Trading {
    address owner;
    address dataRequester;
    
    string private sKey;

    struct Data{
        string dataUID;
        string dataStyle;
        uint256 amount;
        string description;
        uint256 dataPrice;
        address dataProvider;
    }

    struct DataEve{
        string DataUID;
        string integrityEve;
        uint256 integritySco;
        string consistencyEve;
        uint256 consistencySco;
        string accuracyEve;
        uint256 accuracySco;
        uint256 qualitySco;
    }

    struct DataProveHash{
        string dataUID;
        string IPFS_hash;
        string Skey_hash;
    }

    struct DataProve{
        string dataUID;
        string IPFS;
        string Skey;
        address Requirer;
    }

    struct DataReq{
        address dataRequirer;
        string dataUID;
    }


    mapping(string => Data) datas;
    mapping(string => DataEve) datasEve;
    mapping(string => DataProveHash)datasProveHash;
    mapping(address => DataProve)datasProve;
    mapping(string =>DataReq)datasReq;

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function dataRegister(address Provider,string memory dataUID, string memory dataStyle,uint256 amount,string memory description,uint256 dataPrice) public
    {
        datas[dataUID].dataProvider=Provider;
        datas[dataUID].dataUID=dataUID;
        datas[dataUID].dataStyle=dataStyle;
        datas[dataUID].amount=amount;
        datas[dataUID].description=description;
        datas[dataUID].dataPrice=dataPrice;
    }

    function checkData(string memory _dataUID) public view returns(address Provider,string memory dataStyle,uint256 amount,string memory description,uint256 dataPrice)
    {
        return(datas[_dataUID].dataProvider,datas[_dataUID].dataStyle,datas[_dataUID].amount,datas[_dataUID].description,datas[_dataUID].dataPrice);
    }

    function dataRequire(string memory _dataUID) public payable
    {
        datasReq[_dataUID].dataUID=_dataUID;
        datasReq[_dataUID].dataRequirer=msg.sender;
    }

    function transferIPFSandKey(string memory _dataUID,address _Requirer,string memory _IPFS,string memory _sKey) public payable
    {
        if(address(_Requirer).balance>=datas[_dataUID].dataPrice)
        {
            datasProve[_Requirer].Requirer=_Requirer;
            datasProve[_Requirer].dataUID=_dataUID;
            datasProve[_Requirer].IPFS=_IPFS;
            datasProve[_Requirer].Skey=_sKey;
            datasProveHash[_dataUID].dataUID=_dataUID;
            datasProveHash[_dataUID].IPFS_hash=bytes32ToString(keccak256(abi.encode(_IPFS)));
            datasProveHash[_dataUID].Skey_hash=bytes32ToString(keccak256(abi.encode(_sKey)));
        }
    }

    function getData() public payable returns(string memory ipfs,string memory skey)
    {
        payable(msg.sender).transfer(datas[datasProve[msg.sender].dataUID].dataPrice);
        return(datasProve[msg.sender].IPFS,datasProve[msg.sender].Skey);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function writeEve(string memory integrityEve,uint256 integritySco,string memory consistencyEve,uint256 consistencySco, string memory accuracyEve,uint256 accuracySco,uint256 qualitySco) public
    {
        datasEve[datasProve[msg.sender].dataUID].DataUID=datasProve[msg.sender].dataUID;
        datasEve[datasProve[msg.sender].dataUID].integrityEve=integrityEve;
        datasEve[datasProve[msg.sender].dataUID].integritySco=integritySco;
        datasEve[datasProve[msg.sender].dataUID].consistencyEve=consistencyEve;
        datasEve[datasProve[msg.sender].dataUID].consistencySco=consistencySco;
        datasEve[datasProve[msg.sender].dataUID].accuracyEve=accuracyEve;
        datasEve[datasProve[msg.sender].dataUID].accuracySco=accuracySco;
        datasEve[datasProve[msg.sender].dataUID].qualitySco=qualitySco;
    }

    function withdraw() public payable{
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    address [10000]miners;
    address [100]Arbiters;
    uint minersNum;

    struct MinerNUm
    {
        uint num;
    }

    mapping(address=>MinerNUm)MN;

    function setMiners(address[] memory _mins,uint _num)public
    {
        minersNum=_num;
        for(uint i=0;i<_num;i++)
        {
            miners[i]=_mins[i];
        }
    }

    event Nam(uint256 weiAmount);

    function setArbiters(uint256 _num) public{
        uint256 random;
        uint256 _random;
        random = uint256(keccak256(abi.encodePacked(block.prevrandao,block.timestamp)))%10000;
        for(uint i=0;i<_num;i++)
        {
            _random=random*(i+1);
            Arbiters[i]=miners[_random%minersNum];
        }
    }
    
    
    
}
