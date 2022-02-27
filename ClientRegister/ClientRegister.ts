import CameraClientService from "../services/cameraClientService";

export default class ClientRegister {

    //this contains a map of clientId to clientServiceInstanceId
    private registeredClients: Map<number, CameraClientService>;
    private totalClientsAdded = 0;
    public clientCount = 0;
    
    constructor() {
        this.registeredClients = new Map<number, CameraClientService>();
    }

    addClientService(clientId:number): CameraClientService {
        this.clientCount++;
        this.totalClientsAdded++;

        const newClient = new CameraClientService(this.totalClientsAdded);
        this.registeredClients.set(clientId, newClient);

        return newClient;
    }

    getClientServiceId(clientId: number): number | null {
         const serviceId = this.registeredClients[clientId].id;

        if(serviceId == 0) return null;
        
        return serviceId;
    }

    getClientService(clientId: number): CameraClientService | null {
        return  this.registeredClients[clientId];
    }

    removeClientServiceId(clientId: number): void {
        this.registeredClients.delete(clientId);
        this.clientCount--;
    }
}