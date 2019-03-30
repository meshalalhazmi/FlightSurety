
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545/'));

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {
    let Status = await config.flightSuretyData.isOperational.call(); 
    if(Status){
        await config.flightSuretyData.setOperatingStatus(false);

    }

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline , "NA", "new Airline", {from: config.firstAirline});
    }
    catch(e) {
        console.log("error in registering an Airline ",e)
    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });
  it('(airline) Airline can be registered, but does not participate in contract until it submits funding of 10 ether', async () => {
    
    // ARRANGE
     let newAirline = accounts[2];
     let newAirline2 = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.fundAirline( {from: newAirline, value: web3.utils.toWei("5","ether") });
    }
    catch(e) {
        console.log("error in funding an Airline ",e)
    }
    try {
        await config.flightSuretyApp.registerAirline(newAirline2 , "NA", "new Airline", {from: newAirline});
    }
    catch(e) {
        console.log("error in registering an Airline ",e)
    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, true, "Airline should  be able to register another airline if it has provided funding");

  });

  it('(airlines) Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines', async () => {
    
    // ARRANGE
   
     let Airline10 = accounts[10];
     let Airline11 = accounts[11];
     let Airline12 = accounts[12];
     let Airline13 = accounts[13];
     let Airline14 = accounts[14];
     let Airline15 = accounts[15];
     let Airline16 = accounts[16];



     let newAirline3 = accounts[3];
     let newAirline4 = accounts[4];
     let newAirline5 = accounts[5];
     let newAirline6 = accounts[6];
     let newAirline7 = accounts[7];
     let newAirline8 = accounts[8];
     



    // ACT
    try {
        await config.flightSuretyApp.fundAirline( {from: Airline10, value: web3.utils.toWei("5","ether") });
        await config.flightSuretyApp.fundAirline( {from: Airline11, value: web3.utils.toWei("5","ether") });
        await config.flightSuretyApp.fundAirline( {from: Airline12, value: web3.utils.toWei("5","ether") });
        await config.flightSuretyApp.fundAirline( {from: Airline13, value: web3.utils.toWei("5","ether") });
        await config.flightSuretyApp.fundAirline( {from: Airline14, value: web3.utils.toWei("5","ether") });
        await config.flightSuretyApp.fundAirline( {from: Airline15, value: web3.utils.toWei("5","ether") });

    }
    catch(e) {
        console.log("error in funding an Airline ",e)
    }
    try {
        await config.flightSuretyApp.registerAirline(newAirline3 , "NA", "new Airline", {from: Airline10});
        await config.flightSuretyApp.registerAirline(newAirline4, "NA", "new Airline", {from: Airline10});
        await config.flightSuretyApp.registerAirline(newAirline4, "NA", "new Airline", {from: Airline11});
        await config.flightSuretyApp.registerAirline(newAirline4, "NA", "new Airline", {from: Airline12});
        await config.flightSuretyApp.registerAirline(newAirline5 , "NA", "new Airline", {from: Airline10});
        await config.flightSuretyApp.registerAirline(newAirline5 , "NA", "new Airline", {from: Airline11});
        await config.flightSuretyApp.registerAirline(newAirline5 , "NA", "new Airline", {from: Airline12});
        // await config.flightSuretyApp.registerAirline(newAirline6 , "NA", "new Airline", {from: newAirline});
        // await config.flightSuretyApp.registerAirline(newAirline7 , "NA", "new Airline", {from: newAirline});
        // await config.flightSuretyApp.registerAirline(newAirline8 , "NA", "new Airline", {from: newAirline});
     }
    catch(e) {
        console.log("error in registering an Airline  ",e)
    }
    let result = await config.flightSuretyApp.isAirline.call(newAirline3); 
    let result2 = await config.flightSuretyApp.isAirline.call(newAirline4); 
    let result3 = await config.flightSuretyApp.isAirline.call(newAirline5); 
    // let result4 = await config.flightSuretyApp.isAirline.call(newAirline6); 
    // let result5 = await config.flightSuretyApp.isAirline.call(newAirline7); 
    // let result6 = await config.flightSuretyApp.isAirline.call(newAirline8); 

    // ASSERT
    assert.equal(result && result2 && result3 , true, "Airline should  be able to register if other airlines vote for it");
    // assert.equal(result && result2 && result3 && result4 && result5&& result6 , true, "Airline should  be able to register another airline if it has provided funding");
  
  });
  it('(airline) Airline can  register a flight', async () => {
    
    // ARRANGE
     let newAirline = accounts[2];
    

    // ACT
       // ACT
    try {
        await config.flightSuretyApp.fundAirline( {from: newAirline, value: web3.utils.toWei("5","ether") });
    }
    catch(e) {
        console.log("error in funding an Airline ",e)
    }
    try {
        await config.flightSuretyApp.registerFlight(web3.utils.utf8ToHex('A101') , Math.floor(Date.now() / 1000), {from: newAirline});
    }
    catch(e) {
        console.log("error in registering a flight ",e)
    }
    let result = await config.flightSuretyApp.flighStatus.call(web3.utils.utf8ToHex('A101')); 

    // ASSERT
    assert.equal(result, true, "Airline should  be able to register a flight");

  });

});
