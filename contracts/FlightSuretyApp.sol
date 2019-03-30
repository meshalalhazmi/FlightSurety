pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)
    uint256 public constant AIRLINES_REGISTRATION_FEE = 5 ether;
    mapping (address => uint256) public AirlinesBalances;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    FlightSuretyData flightSuretyData;
  
    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    address private contractOwner;          // Account used to deploy contract

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;        
        address airline;
        address[] registerPassengers;

    }
     mapping(string => Flight) private flights;
    struct Airline {
        bool isRegistered;
        string name;
        string id;
        bool isFunded;
        address[] multiCalls ;
    }

    mapping(address => Airline) private airlines;
    uint private  M = 1;

     struct Passenger {
         string flightName;
        uint256 amount;
        uint256 fundAvailable;  
        
    }
   
    mapping(address => Passenger) private passengers;

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
         // Modify to call data contract's status
        require(true, "Contract is currently not operational");  
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }
    modifier isAirlineAuthorized()
    {
        require(airlines[msg.sender].isFunded, "Airline is not funded");
        _;
    }



    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor
                                (
                                    address dataContract
                                    
                                ) 
                                public 
    {
        contractOwner = msg.sender;
         
        flightSuretyData = FlightSuretyData(dataContract);
    }
     function isAirline(address airlineAddress) 
                              public
                            view 
                            returns(bool) 
    {
         
        return    flightSuretyData.isAirline(airlineAddress) && airlines[airlineAddress].isRegistered;

    }

     function flighStatus(string flightName) 
                              public
                            view 
                            returns(bool) 
    {
         
        return    flights[flightName].isRegistered;

    }
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() 
                            public 
                              view
                            returns(bool) 
    {
        return flightSuretyData.isOperational(); 
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
    function withdrawFund() public{

 
   
 
         require(passengers[msg.sender].fundAvailable > 0, "no fund available");
         
        uint amount = passengers[msg.sender].fundAvailable;
        passengers[msg.sender].fundAvailable = 0;
        passengers[msg.sender].flightName = '';
        passengers[msg.sender].amount = 0;
         msg.sender.transfer(amount);
         
    }
  
   /**
    * @dev Add an airline to the registration queue
    *
    */   
    function fundAirline() payable public returns(bool success){
         require(msg.value >= AIRLINES_REGISTRATION_FEE, "Registration fee is required");
        require(airlines[msg.sender].isFunded == false, "Airline is already funded");

         
         AirlinesBalances[msg.sender] = msg.value;
         airlines[msg.sender].isFunded = true;

         

        return true;
    }
   
    function registerAirline
                            (    
                                address newAirline,
                                string id,
                                string name
                            )
                            external
                             isAirlineAuthorized
                            
                            returns(bool success, uint256 votes)
    {
        if(airlines[newAirline].multiCalls.length == 0){
            address[] memory multiCalls =  new address[](1);
            multiCalls[0] = msg.sender;
            bool isRegistered = false;
            if(M < 4){
                isRegistered = true; 
                flightSuretyData.registerAirline(newAirline);
                M = M.add(1);
            }
            
            airlines[newAirline] = Airline({
                id: id,
                isRegistered: isRegistered,
                isFunded: false,
                name: name,
                multiCalls: multiCalls
            });
            
        }else{
            bool isDuplicate = false;
            for(uint c=0; c<airlines[newAirline].multiCalls.length; c++) {
                if (airlines[newAirline].multiCalls[c] == msg.sender) {
                    isDuplicate = true;
                    break;
                }
            }
            require(!isDuplicate, "Caller has already called this function.");
            airlines[newAirline].multiCalls.push(msg.sender);
            if (airlines[newAirline].multiCalls.length >= M.div(2) || M < 4 ) {
                  M = M.add(1);    
                  airlines[newAirline].isRegistered = true;
                flightSuretyData.registerAirline(newAirline);

                      
            }
        }
        return (success, airlines[newAirline].multiCalls.length);
    }

    


   /**
    * @dev Register a future flight for insuring.
    *
    */  

     

  function buy
                            (      
                                    string name                         
                            )
                            external
                             
                             
                            payable
    {
    require(msg.value <= 1 ether, "insurance amount is incorrect");
    require(flights[name].isRegistered, "incorrect flight name");
         
        passengers[msg.sender] = Passenger({
            flightName:name ,
            amount: msg.value ,
            fundAvailable: 0 
            
            });  
            flights[name].registerPassengers.push(msg.sender);
   
            
    }
    function registerFlight
                                (
                                     
                                string name,
                                uint256 timestamp
                                )
                                external
                                isAirlineAuthorized
                                
    {
             address[] memory registerPassengersArray =  new address[](1);
             registerPassengersArray[0] = msg.sender;
        flights[name] = Flight({
            isRegistered: true,
            statusCode: STATUS_CODE_ON_TIME,
            updatedTimestamp:timestamp,
            airline: msg.sender,
            registerPassengers:   registerPassengersArray 
                 
            }); 
    }
    
   /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus
                                (
                                     
                                    string  flight,
                                     
                                    uint8 statusCode
                                )
                                internal
                                 
    {
             
            
        flights[flight].statusCode =  statusCode;
            if(statusCode == 20){
            for(uint c=0; c < flights[flight].registerPassengers.length ; c++) {
                 passengers[flights[flight].registerPassengers[c]].fundAvailable = (passengers[flights[flight].registerPassengers[c]].amount.mul(3)).div(2);
            }
            }
 
            
    }


    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airline,
                            string flight,
                            uint256 timestamp                            
                        )
                        external
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key] = ResponseInfo({
                                                requester: msg.sender,
                                                isOpen: true
                                            });

        emit OracleRequest(index, airline, flight , timestamp);
    } 


// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    // mapping(address => Oracle) private oracles;
    mapping(address => Oracle) public oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);

     // Register an oracle with the contract
    function registerOracle
                            (
                            )
                            external
                            payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
                                        isRegistered: true,
                                        indexes: indexes
                                    });
 
    }

    function getMyIndexes
                            (
                            )
                            view
                            external
                            returns(uint8[3])
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        // return oracles[msg.sender].indexes;
        return oracles[msg.sender].indexes;
    }




    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            string flight,
                            uint256 timestamp,
                            uint8 statusCode
                        )
                        external
    {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus( flight , statusCode);
        }
    }


    function getFlightKey
                        (
                            address airline,
                            string flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (                       
                                address account         
                            )
                            internal
                            returns(uint8[3])
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   
contract FlightSuretyData {
    function isOperational() 
                             
                            view 
                            external
                            returns(bool) ;
    function registerAirline
                            (   
                                address newAirline
                            ) public;
    function isAirline(address airlineAddress) 
                              external
                            view 
                            returns(bool);
    // function updateEmployee
    //                             (
    //                                 string id,
    //                                 uint256 sales,
    //                                 uint256 bonus

    //                             )
    //                             external;
    
}