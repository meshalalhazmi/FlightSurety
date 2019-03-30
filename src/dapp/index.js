
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {
    
 
    let result = null;
    let contract = new Contract('localhost', () => {

        contract.flightSuretyApp.events.FlightStatusInfo({
         }, (error, event) => { console.log(event); })
        
        


     
        
       
      
        
        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
        DOM.elid('flight-refund-A101').addEventListener('click', async () => {
            contract.withdrawFund(  (error, result) => {
                if(error){
                    console.log("error in flight-refund-A101 ",error);

                }else{
                    console.log("successful funded airline A101 ",result);

                }
            
            })
        })
        DOM.elid('flight-refund-KM433').addEventListener('click', async () => {
            contract.withdrawFund(  (error, result) => {
                if(error){
                    console.log("error in flight-refund-KM433 ",error);

                }else{
                    console.log("successful funded airline KM433 ",result);

                }
            
            })
        })
        DOM.elid('flight-refund-SA333').addEventListener('click', async () => {
            contract.withdrawFund(  (error, result) => {
                if(error){
                    console.log("error in flight-refund-SA333 ",error);

                }else{
                    console.log("successful funded airline SA333 ",result);

                }
            
            })
        })
        DOM.elid('purchasing-flight-insurance-A101').addEventListener('click', async () => {
            let insurance = DOM.elid('flight-insurance1').value;
            if(insurance > 1 || insurance < 0){
                alert("amount is invalid ,,, maximum amount is 1 ETHER")
                return;
            }
            console.log(insurance)
            contract.buyInsurance("A101" , insurance,(error, result) => {
                if(error){
                    console.log("error in transaction details ",error);

                }else{
                    console.log("successful transaction details ",result);

                }
            
            })
        })
        DOM.elid('purchasing-flight-insurance-KM433').addEventListener('click', async () => {
            let insurance = DOM.elid('flight-insurance2').value;
            if(insurance > 1 || insurance < 0){
                alert("amount is invalid ,,, maximum amount is 1 ETHER")
                return;
            }
            console.log(insurance)
            contract.buyInsurance("KM433" , insurance,(error, result) => {
                if(error){
                    console.log("error in transaction details ",error);

                }else{
                    console.log("successful transaction details ",result);

                }
            
            })
        })
        DOM.elid('purchasing-flight-insurance-SA333').addEventListener('click', async () => {
            let insurance = DOM.elid('flight-insurance3').value;
            if(insurance > 1 || insurance < 0){
                alert("amount is invalid ,,, maximum amount is 1 ETHER")
                return;
            }
            console.log(insurance)
            contract.buyInsurance("SA333" , insurance,(error, result) => {
                if(error){
                    console.log("error in transaction details ",error);

                }else{
                    console.log("successful transaction details ",result);

                }
            
            })
        })
        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
           
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
                console.log("fetchFlightStatus",result);
            
            });
      
        })
    
    });
    

})();


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}







