import { stringify } from "querystring";

export default class ClientRegister {

    //this contains a map of clientId to clientServiceInstanceId
    private registeredClients: Map<number, number>;
    private totalClientsAdded = 0;
    public clientCount = 0;
    
    constructor() {
        this.registeredClients = new Map<number, number>();

    }

    addClientService(clientId:number): number {
        this.clientCount++;
        this.totalClientsAdded++;

        this.registeredClients.set(clientId, this.totalClientsAdded);

        return this.totalClientsAdded;
    }

    getClientServiceId(clientId: number): number | null {
        const serviceId = this.registeredClients[clientId];

        if(serviceId == 0) return null;
        
        return serviceId;
    }

    removeClientServiceId(clientId: number): void {
        this.registeredClients.delete(clientId);
    }

}



