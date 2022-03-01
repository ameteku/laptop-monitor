import ClientRegister from "../ClientRegister/ClientRegister";
import { videoFrame } from "../models/videoContainer";
import { Result } from "../models/videoResultsContainer";
import DBConnector from "./dbConnector";

export default class ClientDataDelegate {
    register: ClientRegister;

    constructor(register: ClientRegister) {
        this.register = register;
    }

    addVideo(clientId: string, videoFrames: Array<videoFrame>): boolean {
       const clientService = this.register.getClientService(clientId);
        if(clientService == null) {
            console.log("service does not exits", clientService, "in register: ", this.register);
            return false;
        }
       
        clientService.addVideoFeed(videoFrames);
        clientService.processFrames();
        return true;
    }

    getResults(clientId: string): Array<Result>  {
        const clientService = this.register.getClientService(clientId);

        if(clientService == null) {
            console.log("No client with id");
            return null;
        }
       
        return clientService.getResults();
    }
    
}