pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    mapping(address => uint256) private authorizedContracts;      // Mapping for storing employees
    
    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true; 
    address[] airlines = new address[](0);
    // Blocks all state changes throughout the contract if false
    // struct Airline {
    //     bool isRegistered;
    //     string name;
    //     string id;
    //     bool isFunded;
    //     address[] multiCalls ;
    // }

    // mapping(address => Airline) private airlines;
    // uint private  M = 1;
    
     /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                    address firstAirline
                                ) 
                                public 
    {
        contractOwner = msg.sender;
          airlines.push(firstAirline);
          
    }

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
        require(operational, "Contract is currently not operational");
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
    modifier isCallerAuthorized()
    {
        require(authorizedContracts[msg.sender] == 1, "Caller is not authorized");
        _;
    }
   
   
    function authorizeCaller(address contractAddress) external requireContractOwner{
        authorizedContracts[contractAddress] = 1;
    }
    function deauthorizeCaller(address contractAddress) external requireContractOwner{
        authorizedContracts[contractAddress] = 0;

    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            external 
                            view 
                            returns(bool) 
    {
        return operational;
    }
    
    function isAirline(address airlineAddress) 
                            external 
                            view 
                            returns(bool) 
    {
        // return (airlines[airlineAddress].multiCalls.length > 0);
        for(uint c=0; c<airlines.length; c++) {
                    if (airlines[c]== airlineAddress) {
                    return  true;
                     
                }
                 
            }
        return  false;

    }
    


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                             
                            requireContractOwner
    {
        require(mode != operational, "New mode must be different from existing mode");
        // require(userProfiles[msg.sender].isAdmin, "Caller is not an admin");

        
        operational = mode;
    }
    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (   
                                address newAirline
                                // string id,
                                // string name
                                 
                            )
                            external
                            requireIsOperational
                            isCallerAuthorized 
                            // isAirlineAuthorized  
                             
    {
                  airlines.push(newAirline);

       
    }

     
   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (                             
                            )
                            external
                            requireIsOperational
                            isCallerAuthorized
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                requireIsOperational
                                isCallerAuthorized
                                 
    {
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            requireIsOperational
                            isCallerAuthorized
                             
    {
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            requireIsOperational
                            isCallerAuthorized
                            payable
    {
        
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        
                        internal
                        requireIsOperational
                        isCallerAuthorized
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

