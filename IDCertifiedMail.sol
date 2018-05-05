pragma solidity ^0.4.11;

contract IDCertifiedMail {
   
    //En este caso no es necesario el estado created, ya que solo se usar� el contrato en caso de cancelaci�n o finalizaci�n.
    enum State {cancelled, finished }
    address ttp;
    struct Message{
       uint id; //El identificador corresponde con el ID del mensaje en la BD del servidor.
       address sender;
       address receiver;
       string hB;
       string keyB;
       State state;
   }
   
   Message[] messages;
   
   
    constructor(){
        ttp = msg.sender;
    }
        
    event cancelEvent(
        string cancelResponse
        );
        
    event finishEvent(
        string resolveResponse
        );      
        
    
    //Funci�n para cancelar el intercambio
    function cancel(uint id,address receiver) {
        //Variable que nos indica la posici�n del array en la que se encuentra el mensaje con el id  especificado
        //o -1 si no existe ningun mensaje con ese id.
         int existe = idExists(id);
         if(existe!=-1){
             if(msg.sender==messages[uint(existe)].sender){
                cancelEvent(messages[uint(existe)].hB);
             }
         }else{
            //Si el mensaje no existe lo creamos con el estado cancelado y con el identificador especificado 
            Message memory newMessage = Message(id,msg.sender,receiver,"","",State.cancelled);
            messages.push(newMessage);
         }
    }
    
    //Funci�n para finalizar el intercambio.
    
    function finish(uint id,address sender,address receiver,string _hB, string _keyB){
        if(msg.sender==ttp){
            int existe = idExists(id);
            if(existe!=-1){
                //Si el mensaje existe, comprobamos en que estado se encuentra
                if(messages[uint(existe)].state==State.cancelled){
                    //Si el mensaje existe y se encuentra cancelado
                    //llamamos al evento de finalizaci�n indicandole el estado cancelado.
                    finishEvent(stateToString(messages[uint(existe)].state));
                }
            }else{
                //Si el mensaje no ha sido creado, lo creamos indicandole hB y keyB.
                Message memory newMessage = Message(id,sender,receiver,_hB,_keyB,State.finished);
                messages.push(newMessage);
            }
        }
    
    }    
    
    //Funci�n para comprobar si hay algun mensaje con el id especificado.
    function idExists (uint id) private returns (int){
        for (int i=0; i<int(messages.length);i++){
            if(messages[uint(i)].id==id){
                return i;
            }
        }
        return -1;
    }
    
    function stateToString(State state) view private returns (string){
        if (state==State.cancelled) return "Cancelled";
        if (state==State.finished) return "Finished";
    }
    
    function gethb(uint id) view public returns (string){
        return messages[uint(idExists(id))].hB;
    }
    
    function getState(uint id) view public returns(State){
        return messages[uint(idExists(id))].state;
    }
}