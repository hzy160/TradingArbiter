// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

contract Trading {
    address Owner;
    address Requirer;

    struct Data {
        uint256 dataPrice;
        uint256 dataDeposit;
        uint256 dataEveAmount;
        uint256 amount;
        address dataProvider;
        string Datastyle;
        string description;
        string IPFS;
        bool tradeFlag;
        uint256 arbitrFlag;
        string DataPK;
    }

    struct DataEve {
        string integrityEve;
        string consistencyEve;
        string accuracyEve;
        uint8 integritySco;
        uint8 consistencySco;
        uint8 accuracySco;
        uint8 qualitySco;
    }

    struct DataKey {
        address RequirerAdd;
        string RequirerPK;
        string OwnerSK;
    }

    struct datasEve {
        uint256 buyerNum;
        DataEve[1000] dataEves;
    }

    mapping(string => Data) Datas;
    mapping(string => DataKey) DataKeys;
    mapping(string => datasEve) DatasEves;

    function dataRegister(
        string memory DataPk,
        string memory IPFS,
        string memory dataUID,
        string memory Datastyle,
        uint256 amount,
        string memory description,
        uint256 dataPrice,
        uint256 dataDeposit
    ) public {
        payable(address(this)).transfer(Datas[dataUID].dataDeposit);
        Datas[dataUID].dataProvider = msg.sender;
        Datas[dataUID].IPFS = IPFS;
        Datas[dataUID].Datastyle = Datastyle;
        Datas[dataUID].amount = amount;
        Datas[dataUID].description = description;
        Datas[dataUID].dataPrice = dataPrice;
        Datas[dataUID].dataDeposit = dataDeposit;
        Datas[dataUID].tradeFlag = false;
        Datas[dataUID].arbitrFlag = 0;
        Datas[dataUID].amount = 0;
        Datas[dataUID].DataPK = DataPk;
        DatasEves[dataUID].buyerNum = 0;
    }

    function checkData(string memory _dataUID)
        public
        view
        returns (
            address Provider,
            string memory Datastyle,
            uint256 amount,
            string memory description,
            uint256 dataPrice,
            bool tradeFlag,
            uint256 arbitrFlag
        )
    {
        return (
            Datas[_dataUID].dataProvider,
            Datas[_dataUID].Datastyle,
            Datas[_dataUID].amount,
            Datas[_dataUID].description,
            Datas[_dataUID].dataPrice,
            Datas[_dataUID].tradeFlag,
            Datas[_dataUID].arbitrFlag
        );
    }

    function getData(string memory _dataUID, string memory _RequirerPK)
        public
        payable
        returns (string memory IPFS)
    {
        if (Datas[_dataUID].tradeFlag == false) {
            payable(address(this)).transfer(
                Datas[_dataUID].dataPrice + Datas[_dataUID].dataDeposit
            ); //在正式交易中押金应由双方进行协商
            Datas[_dataUID].tradeFlag = true;
            Datas[_dataUID].arbitrFlag = 0;
            DataKeys[_dataUID].RequirerAdd = msg.sender;
            DataKeys[_dataUID].RequirerPK = _RequirerPK;
            return (Datas[_dataUID].IPFS);
        }
    }

    function transKey(string memory _dataUID, string memory _OwnerSk)
        public
        payable
    {
        if (Datas[_dataUID].dataProvider == msg.sender) {
            payable(address(this)).transfer(
                Datas[_dataUID].dataPrice + Datas[_dataUID].dataDeposit
            );
            DataKeys[_dataUID].OwnerSK = _OwnerSk;
        }
    }

    function getKey(string memory _dataUID)
        public
        payable
        returns (string memory OwnerSK, string memory OwnerPK)
    {
        if (DataKeys[_dataUID].RequirerAdd == msg.sender) {
            return (DataKeys[_dataUID].OwnerSK, Datas[_dataUID].DataPK);
        }
    }

    modifier OnlyBuyer(string memory _dataUID) {
        require(DataKeys[_dataUID].RequirerAdd == msg.sender);
        _;
    }

    function writeEve(
        string memory _dataUID,
        string memory integrityEve,
        uint8 integritySco,
        string memory consistencyEve,
        uint8 consistencySco,
        string memory accuracyEve,
        uint8 accuracySco,
        uint8 qualitySco
    ) public payable OnlyBuyer(_dataUID) {
        uint256 Id = DatasEves[_dataUID].buyerNum++;
        DatasEves[_dataUID].dataEves[Id].integrityEve = integrityEve;
        DatasEves[_dataUID].dataEves[Id].integritySco = integritySco;
        DatasEves[_dataUID].dataEves[Id].consistencyEve = consistencyEve;
        DatasEves[_dataUID].dataEves[Id].consistencySco = consistencySco;
        DatasEves[_dataUID].dataEves[Id].accuracyEve = accuracyEve;
        DatasEves[_dataUID].dataEves[Id].accuracySco = accuracySco;
        DatasEves[_dataUID].dataEves[Id].qualitySco = qualitySco;
        Datas[_dataUID].tradeFlag = false;
        payable(msg.sender).transfer(Datas[_dataUID].dataDeposit);
        payable(Datas[_dataUID].dataProvider).transfer(
            Datas[_dataUID].dataPrice * 2 + Datas[_dataUID].dataDeposit
        );
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    fallback() external payable {}

    receive() external payable {}

    uint256 minersNum = 0;

    struct miner {
        address minerAdd;
        string minerPK;
        string minerPro;
    }

    struct arbReq {
        string dataUID;
        string IPFS;
        string wrongProve;
        uint8 Abtype; //标记仲裁类型
        uint256 ID;
    }

    struct arbiter {
        uint256 num;
        uint256 time;
        uint256 Reward;
        int8 end;
        int8[] arbitResults;
        bool[] getRewards;
        uint256[] arbiterAddHash;
        string[] AbPK;
        string[] IPFS;
    }

    mapping(uint256 => miner) miners;
    mapping(address => uint8) MinersFlag; //防止一个矿工多次注册
    mapping(address => arbReq) arbs;
    mapping(string => arbiter) arbiters;

    function MinersRegister(string memory minersProve, string memory minerPK)
        public
        returns (string memory flags)
    {
        if (MinersFlag[msg.sender] != 1) {
            miners[minersNum].minerAdd = msg.sender;
            miners[minersNum].minerPro = minersProve;
            miners[minersNum++].minerPK = minerPK;
            MinersFlag[msg.sender] = 1;
            return ("1");
        }
    }

    function setArbiters(
        uint256 _num,
        uint8 _Abtype,
        string memory _wrongProve,
        string memory _dataUID
    ) public {
        payable(address(this)).transfer(Datas[_dataUID].dataDeposit);
        uint256 random;
        uint256 _random;
        Datas[_dataUID].arbitrFlag = _Abtype;
        random =
            uint256(
                keccak256(abi.encodePacked(block.prevrandao, block.timestamp))
            ) %
            10000;
        arbiters[_dataUID].time = block.timestamp;
        arbiters[_dataUID].num = _num;
        for (uint256 i = 0; i < _num; i++) {
            arbiters[_dataUID].arbiterAddHash[i] = uint256(
                keccak256(abi.encodePacked(miners[_random].minerAdd))
            );
            arbiters[_dataUID].arbitResults[i] = 0;
            arbiters[_dataUID].getRewards[i] = true;
            arbiters[_dataUID].AbPK[i] = miners[_random].minerPK;
            _random = (random * (i + 1)) % minersNum;
            arbs[miners[_random].minerAdd].IPFS = Datas[_dataUID].IPFS;
            arbs[miners[_random].minerAdd].wrongProve = _wrongProve;
            arbs[miners[_random].minerAdd].Abtype = _Abtype;
            arbs[miners[_random].minerAdd].dataUID = _dataUID;
            arbs[miners[_random].minerAdd].ID = i;
        }
    }

    function WheatherGetMission() public view returns (string memory dataUID) {
        return (arbs[msg.sender].dataUID);
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

    function getEVidence(uint256 id)
        public
        payable
        returns (
            string memory ev1,
            string memory ev2,
            string memory ev3,
            uint256 ID
        )
    {
        payable(address(this)).transfer(
            Datas[arbs[msg.sender].dataUID].dataDeposit
        );
        if (arbs[msg.sender].Abtype == 1) //IPFS错误
        {
            return (arbs[msg.sender].IPFS, "", "", arbs[msg.sender].ID);
        } else if (arbs[msg.sender].Abtype == 2) //密文错误
        {
            return (
                arbs[msg.sender].wrongProve,
                Datas[arbs[msg.sender].dataUID].DataPK,
                Datas[arbs[msg.sender].dataUID].IPFS,
                arbs[msg.sender].ID
            );
        } else if (arbs[msg.sender].Abtype == 4) //数据外泄
        {
            return (arbs[msg.sender].wrongProve, "", "", arbs[msg.sender].ID);
        } else if (arbs[msg.sender].Abtype == 5) //数据重复售卖
        {
            return (
                arbs[msg.sender].wrongProve,
                arbs[msg.sender].IPFS,
                arbiters[arbs[msg.sender].dataUID].IPFS[id],
                arbs[msg.sender].ID
            );
        } else if (arbs[msg.sender].Abtype == 3) //密钥错误
        {
            return (
                arbs[msg.sender].wrongProve,
                Datas[arbs[msg.sender].dataUID].DataPK,
                "",
                arbs[msg.sender].ID
            );
        }
    }

    function returnResults(
        string memory _dataUID,
        uint256 ID,
        int8 result
    ) public {
        if (
            uint256(keccak256(abi.encodePacked(msg.sender))) ==
            arbiters[_dataUID].arbiterAddHash[ID]
        ) {
            arbiters[_dataUID].arbitResults[ID] = result % 1;
        }
    }

    modifier enoughTime(string memory dataUID) {
        require(block.timestamp - arbiters[dataUID].time >= 60 * 60 * 24);
        _;
    }

    function getResults(string memory dataUID)
        public
        enoughTime(dataUID) //不考虑仲裁方不参与的情况
    {
        int256 end = 0;
        uint256 Reward;
        uint256 Num;
        for (uint256 i = arbiters[dataUID].num - 1; i >= 0; i--) {
            end += arbiters[dataUID].arbitResults[i];
        }
        if (
            arbs[msg.sender].Abtype == 1 ||
            arbs[msg.sender].Abtype == 2 ||
            arbs[msg.sender].Abtype == 3
        ) {
            if (end > 0) //买方错
            {
                payable(Datas[dataUID].dataProvider).transfer(
                    Datas[dataUID].dataDeposit / 4
                );
            }
            //仲裁方设为奇数量，则只会出现非0结果
            else {
                payable(DataKeys[dataUID].RequirerAdd).transfer(
                    Datas[dataUID].dataDeposit / 4
                );
                Datas[dataUID].tradeFlag = false;
            }
            Datas[dataUID].arbitrFlag = 0;
            Datas[dataUID].tradeFlag = false;
        } else if (arbs[msg.sender].Abtype == 4) {
            if (end > 0) //确实外泄
            {
                payable(Datas[dataUID].dataProvider).transfer(
                    Datas[dataUID].dataDeposit / 4
                );
            }
            Datas[dataUID].arbitrFlag = 0;
        } else if (arbs[msg.sender].Abtype == 5) {
            if (end > 0) //确实重复销售
            {
                payable(Datas[dataUID].dataProvider).transfer(
                    Datas[dataUID].dataDeposit / 4
                );
                Datas[dataUID].tradeFlag = true; //在没有交易时设为true，则不会有人可以与其进行交易，也就是对其进行封锁交易
            }
            Datas[dataUID].arbitrFlag = 0;
        }

        if (end > 0) {
            arbiters[dataUID].end = 1;
            Num = uint256(int256(arbiters[dataUID].num) + end);
            Reward = ((Num + 1) / 2) * Datas[dataUID].dataDeposit;
            Reward /= (Num / 2);
        } else {
            arbiters[dataUID].end = -1;
            Num = uint256(int256(arbiters[dataUID].num) - end);
            Reward = ((Num + 1) / 2) * Datas[dataUID].dataDeposit;
            Reward /= (Num / 2);
        }
        arbiters[dataUID].Reward = Reward;
    }

    modifier OnlyAb(string memory dataUID, uint256 ID) {
        require(
            uint256(keccak256(abi.encodePacked(msg.sender))) ==
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
