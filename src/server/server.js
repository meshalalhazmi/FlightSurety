import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import FlightSuretyData from '../../build/contracts/FlightSuretyData.json';

import Config from './config.json';
import Web3 from 'web3';
import express from 'express';
import 'babel-polyfill';

let config = Config['localhost'];
let web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
web3.eth.defaultAccount = web3.eth.accounts[0];
let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
let flightSuretyData = new web3.eth.Contract(FlightSuretyData.abi, config.dataAddress);
let statusCodesArray = [0, 10, 20, 30, 40, 50];

// rigester oracles
  var oracles = []; 

  var accounts = null;
   
  (async () => {
    
    
     accounts = await web3.eth.getAccounts();
     await flightSuretyData.methods.authorizeCaller(config.appAddress).send({from: accounts[0]})

     var registration_fee = await flightSuretyApp.methods.REGISTRATION_FEE().call({ from: accounts[0] })
    console.log("registration_fee ",registration_fee)
    
    for(let a=20; a<41; a++){ 
      var registeredOracle = await flightSuretyApp.methods.registerOracle().send({ from: accounts[a], value: registration_fee,gas:4000000 })  
      console.log("registeredOracle2 " , accounts[a]); 
        var res = await flightSuretyApp.methods.oracles(accounts[a]).call({ from: accounts[0] })
        console.log("oracles ",res) 
 
     let oraclesIndex = await flightSuretyApp.methods.getMyIndexes().call({from: accounts[a]});
    console.log(`Oracle registered: ${oraclesIndex[0]}, ${oraclesIndex[1]}, ${oraclesIndex[2]}`);
     oracles.push([accounts[a], oraclesIndex]);
     }



  })()
  // setTimeout(function() {
  //   console.log("wait accounts",accounts)

  // }, 3000);
  


flightSuretyApp.events.OracleRequest({
    fromBlock: 0
  }, function (error, event) {
    
    if (error) console.log("error",error)
    console.log("event", event.returnValues);

    console.log("event index:", event.returnValues.index);
    var index = event.returnValues.index; 
    var airline = event.returnValues.airline;
    var flight = event.returnValues.flight;
    var timestamp = event.returnValues.timestamp; 

    var statusCode = statusCodesArray[Math.floor(Math.random() * 6)];
    console.log("random statusCode", statusCode)
    // for(var key in oracles){
      console.log("oracles", oracles)
      console.log("oracles.length", oracles.length)
    //   console.log("hey in registeredOracle ", key)
    // }
    oracles.forEach((item) => {
            console.log("item in registeredOracle ", item)
            if(  item[1].includes(index)){
              console.log("allowed oracle ", item[1]);
              (async () => {
                console.log("submitOracleResponse ", index, airline, flight, timestamp, statusCode);
 
                await flightSuretyApp.methods.submitOracleResponse(index, airline, flight, timestamp, statusCode).send({ from: item[0] , gas:5555555});
            })();
            }
        
    })
   
 
});
flightSuretyApp.events.FlightStatusInfo()
      .on('data', log => {
        const {
          event,
          returnValues: { flight, dest, timestamp, status }
        } = log
        console.log(`${event}: flight ${flight}, timestamp ${timestamp}, status ${status}`)
      })
      .on('error', error => { console.log(error) })


const app = express();
app.get('/api', (req, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    })
})

export default app;


