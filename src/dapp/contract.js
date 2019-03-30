import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {
    constructor(network, callback) {

        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];
    }

    initialize(callback) {
        this.web3.eth.getAccounts((error, accts) => {
           
            this.owner = accts[0];

            let counter = 1;
            
            while(this.airlines.length < 5) {
                this.airlines.push(accts[counter++]);
            }

            while(this.passengers.length < 5) {
                this.passengers.push(accts[counter++]);
            }
            this.fundAirline((error, result) => {
                if(error){
                  console.log("fundAirline A101 error" ,error)

                } 

                    this.registerFlight("A101" ,(error, result) => {
                        if(error){
                          console.log("registerFlight2 A101 error" ,error)
      
                        }else{          
                                      console.log("A101 " ,result)
      
                      }
                    }); 
                    this.registerFlight("KM433" ,(error, result) => {
                        if(error){
                          console.log("registerFlight2 KM433 error" ,error)
      
                        }else{          
                                      console.log("KM433 " ,result)
      
                      }
                    }); 
                    this.registerFlight("SA333" ,(error, result) => {
                        if(error){
                          console.log("registerFlight2 A101 error" ,error)
      
                        }else{          
                                      console.log("SA333 " ,result)
      
                      }
                    }); 

              
            }); 
             

            callback();
        });
    }
// for simplicity I will assume only one airline is registered 

    isOperational(callback) {
       let self = this;
       self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }

    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        console.log("payload",payload)
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }
// for simplicity I will assume only one airline is registered 
    buyInsurance(flight,amount, callback) {
        let self = this;
        let payload = {
            flight: flight,
            amount: amount
        } 
        console.log("payload",payload)
        self.flightSuretyApp.methods
            .buy(flight   )
            .send({ from: self.owner , gas: 5555555, value: this.web3.utils.toWei(amount,"ether") }, (error, result) => {
                callback(error, result);
            });
    }
    registerFlight(flight, callback) {
        let self = this;
          
        self.flightSuretyApp.methods
            .registerFlight(flight,Math.floor(Date.now() / 1000)   )
            .send({ from: self.owner , gas: 5555555 }, (error, result) => {
                callback(error, result);
            });
    }
    fundAirline( callback) {
        let self = this;
          
        self.flightSuretyApp.methods
            .fundAirline(   )
            .send({ from: self.owner ,value: this.web3.utils.toWei("5","ether")}, (error, result) => {
                callback(error, result);
            });
    }
    withdrawFund( callback) {
        let self = this;
          
        self.flightSuretyApp.methods
            .withdrawFund(   )
            .send({ from: self.owner }, (error, result) => {
                callback(error, result);
            });
    }
    
    

}