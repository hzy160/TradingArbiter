// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

contract Trading {
    uint256 minerNum = 0;

    struct Data {
        uint256 daPri;
        uint256 arbFlag;
        address daPrer;
        string descp;
        string IPFS;
        string DataPK;
    }

    struct DataEve {
        uint256 qualSco;
        string Eve;
    }

    struct DataKey {
        address ReqAdd;
        string ReqPK;
        string OwnerSK;
    }

    struct miner {
        address minerAdd;
        string minerPK;
        string minerPro;
    }

    struct arbReq {
        uint256 Abtype; //标记仲裁类型
        uint256 ID;
        string dataUID;
        string IPFS;
        string wrongProve;
    }

    struct arbiter {
        uint256 num;
        uint256 time;
        uint256 Reward;
        bytes32[9] arbiterAddHash;
        int8 end;
        int8[9] arbitResults;
        bool[9] getRewards;
        string[9] AbPK;
        string[9] IPFS;
    }

    mapping(string => Data) Datas;
    mapping(string => DataKey) DataKeys;
    mapping(string => DataEve) DataEves;

    mapping(uint256 => miner) miners;
    mapping(address => uint8) MinersFlag; //防止一个矿工多次注册
    mapping(address => arbReq) arbs;
    mapping(string => arbiter) arbiters;

    function dataRegister(
        string memory DataPk,
        string memory IPFS,
        string memory dataUID,
        string memory descp,
        uint256 daPri
    ) public payable {
        payable(address(this)).transfer(daPri);
        Datas[dataUID].daPrer = msg.sender;
        Datas[dataUID].IPFS = IPFS;
        Datas[dataUID].descp = descp;
        Datas[dataUID].daPri = daPri;
        Datas[dataUID].arbFlag = 0;
        Datas[dataUID].DataPK = DataPk;
    }


    modifier noBuyer(string memory _dataUID) {
        require(Datas[_dataUID].arbFlag == 0);
        _;
    }

    function getData(string memory _dataUID, string memory _ReqPK)
        public
        payable
        noBuyer(_dataUID)
        returns (string memory IPFS)
    {
        payable(address(this)).transfer(Datas[_dataUID].daPri * 2); //在正式交易中押金应由双方进行协商
        Datas[_dataUID].arbFlag = 9;
        DataKeys[_dataUID].ReqAdd = msg.sender;
        DataKeys[_dataUID].ReqPK = _ReqPK;
        return (Datas[_dataUID].IPFS);
    }

    modifier isOwner(string memory _dataUID) {
        require(Datas[_dataUID].daPrer == msg.sender);
        _;
    }

    function transKey(string memory _dataUID, string memory _OwnerSk)
        public
        payable
        isOwner(_dataUID)
    {
        payable(address(this)).transfer(Datas[_dataUID].daPri * 2);
        DataKeys[_dataUID].OwnerSK = _OwnerSk;
    }

    modifier OnlyBuyer(string memory _dataUID) {
        require(DataKeys[_dataUID].ReqAdd == msg.sender);
        _;
    }

    function getKey(string memory _dataUID)
        public
        payable
        OnlyBuyer(_dataUID)
        returns (string memory OwnerSK, string memory OwnerPK)
    {
        return (DataKeys[_dataUID].OwnerSK, Datas[_dataUID].DataPK);
    }

    function writeEve(
        string memory _dataUID,
        string memory Eve,
        uint8 qualSco
    ) public payable OnlyBuyer(_dataUID) {
        DataEves[_dataUID].Eve = Eve;
        DataEves[_dataUID].qualSco = qualSco;
        Datas[_dataUID].arbFlag = 0;
        payable(msg.sender).transfer(Datas[_dataUID].daPri);
        payable(Datas[_dataUID].daPrer).transfer(Datas[_dataUID].daPri * 3);
    }

    fallback() external payable {}

    receive() external payable {}

    modifier notRegister() {
        require(MinersFlag[msg.sender] != 1);
        _;
    }

    function MinersRegister(string memory minersProve, string memory minerPK)
        public
        notRegister
        returns (string memory flags)
    {
        miners[minerNum].minerAdd = msg.sender;
        miners[minerNum].minerPro = minersProve;
        miners[minerNum++].minerPK = minerPK;
        MinersFlag[msg.sender] = 1;
        return ("1");
    }

    function setArbiters(
        uint256 _num,
        uint256 _Abtype,
        string memory _wrongProve,
        string memory _dataUID
    ) public {
        payable(address(this)).transfer(Datas[_dataUID].daPri);
        uint256 random;
        uint256 _random;
        address tmp;
        string memory IPFS = Datas[_dataUID].IPFS;
        Datas[_dataUID].arbFlag = _Abtype;
        random =
            uint256(
                keccak256(abi.encodePacked(block.prevrandao, block.timestamp))
            ) %
            1000;
        arbiters[_dataUID].time = block.timestamp;
        arbiters[_dataUID].num = _num;
        for (uint256 i = 0; i < _num; i++) {
            _random = (random * (i + 1)) % minerNum;
            arbiters[_dataUID].arbiterAddHash[i] = keccak256(
                abi.encodePacked(miners[_random].minerAdd)
            );
            tmp = miners[_random].minerAdd;
            arbiters[_dataUID].arbitResults[i] = 0;
            arbiters[_dataUID].getRewards[i] = true;
            arbiters[_dataUID].AbPK[i] = miners[_random].minerPK;
            arbs[tmp].IPFS = IPFS;
            arbs[tmp].wrongProve = _wrongProve;
            arbs[tmp].Abtype = _Abtype;
            arbs[tmp].dataUID = _dataUID;
            arbs[tmp].ID = i;
        }
    }

    function getAbK(string memory _dataUID, uint256 i)
        public
        view
        returns (string memory iPk)
    {
        return (arbiters[_dataUID].AbPK[i]);
    }

    function transAbIPFS(
        string memory _dataUID,
        uint256 i,
        string memory IPFS
    ) public {
        arbiters[_dataUID].IPFS[i] = IPFS;
    }

    function getEVidence()
        public
        payable
        returns (
            string memory ev1,
            string memory ev2,
            string memory ev3,
            uint256 _ID
        )
    {
        payable(address(this)).transfer(Datas[arbs[msg.sender].dataUID].daPri);

        uint256 Abtype = arbs[msg.sender].Abtype;
        uint256 ID = arbs[msg.sender].ID;
        string memory wrongProve = arbs[msg.sender].wrongProve;
        string memory IPFS = arbs[msg.sender].IPFS;
        string memory PK = Datas[arbs[msg.sender].dataUID].DataPK;
        if (Abtype == 1) //IPFS错误
        {
            return (IPFS, "", "", ID);
        } else if (Abtype == 2) //密文错误
        {
            return (wrongProve, PK, IPFS, ID);
        } else if (Abtype == 4) //数据外泄
        {
            return (wrongProve, "", "", ID);
        } else if (Abtype == 5) //数据重复售卖
        {
            return (wrongProve,IPFS,arbiters[arbs[msg.sender].dataUID].IPFS[ID],ID);
        } else if (Abtype == 3) //密钥错误
        {
            return (wrongProve, PK, "", ID);
        }
    }

    modifier isAb(string memory _dataUID, uint256 ID) {
        require(
            keccak256(abi.encodePacked(msg.sender)) ==
                arbiters[_dataUID].arbiterAddHash[ID]
        );
        _;
    }

    function returnResults(
        string memory _dataUID,
        uint256 ID,
        int8 result
    ) public isAb(_dataUID, ID) {
        if (result > 0) {
            arbiters[_dataUID].arbitResults[ID] = 1;
        } else if (result < 0) {
            arbiters[_dataUID].arbitResults[ID] = -1;
        }
    }

    modifier enoughTime(string memory dataUID) {
        require(block.timestamp - arbiters[dataUID].time >= 86400);
        _;
    }

    function getResults(string memory dataUID)
        public
        payable
        enoughTime(dataUID) //不考虑仲裁方不参与的情况
    {
        int256 end = 0;
        uint256 Reward;
        uint256 Num;
        uint256 dataRep = Datas[dataUID].daPri / 4;
        uint256 arbTmp = Datas[dataUID].arbFlag;
        address buyer = DataKeys[dataUID].ReqAdd;
        address owner = Datas[dataUID].daPrer;
        for (uint256 i = 0; i < arbiters[dataUID].num; i++) {
            end += arbiters[dataUID].arbitResults[i];
        } //仲裁方设为奇数量，则只会出现非0结果

        if (arbTmp < 4) {
            if (end > 0) //买方错
            {
                payable(owner).transfer(dataRep);
            } else {
                payable(buyer).transfer(dataRep);
            }
            Datas[dataUID].arbFlag = 0;
        } else if (arbTmp == 4) {
            if (end > 0) //确实外泄
            {
                payable(owner).transfer(dataRep);
            }
            Datas[dataUID].arbFlag = 0;
        } else if (arbTmp == 5) {
            if (end > 0) //确实重复销售
            {
                payable(owner).transfer(dataRep);
                Datas[dataUID].arbFlag = 9; //在没有交易时设为true，则不会有人可以与其进行交易，也就是对其进行封锁交易
            } else {
                Datas[dataUID].arbFlag = 0;
            }
        }

        if (end > 0) {
            arbiters[dataUID].end = 1;
            Num = uint256(int256(arbiters[dataUID].num) + end);
        } else {
            arbiters[dataUID].end = -1;
            Num = uint256(int256(arbiters[dataUID].num) - end);
        }
        Reward = ((Num + 1) * 2) * dataRep;
        Reward /= (Num / 2);
        arbiters[dataUID].Reward = Reward;
    }

    modifier OnlyAb(string memory dataUID, uint256 ID) {
        require(
            keccak256(abi.encodePacked(msg.sender)) ==
                arbiters[dataUID].arbiterAddHash[ID] &&
                arbiters[dataUID].end == arbiters[dataUID].arbitResults[ID] &&
                arbiters[dataUID].getRewards[ID] == true
        );
        _;
    }

    function getRewards(string memory dataUID, uint256 ID)
        public
        payable
        OnlyAb(dataUID, ID) //仲裁方收取奖励
    {
        payable(msg.sender).transfer(arbiters[dataUID].Reward);
        arbiters[dataUID].getRewards[ID] = false;
    }
}
