import CameraClientService from "../services/cameraClientService";
import IdCreator from "../utility/idCreator";

export default class ClientRegister {

    //this contains a map of clientId to clientServiceInstanceId
    private registeredClients: Map<string, CameraClientService>;
    private totalLifetimeClientsAdded = 0;
    public clientCount = 0;
    idCreator: IdCreator;
    
    constructor() {
        this.registeredClients = new Map<string, CameraClientService>();
        this.idCreator = new IdCreator();
    }

    get totalClients() {
        return this.totalLifetimeClientsAdded;
    } 

    get currentClientCount() {
        return this.totalClients;
    }

    isRegisteredClient(clientId: string) {
        return this.getClientServiceId(clientId) !== null;
    }

    addClientService(clientId:string) {
        this.clientCount++;
        this.totalLifetimeClientsAdded++;
        const newId = this.idCreator.generateId();

        const newClient = new CameraClientService(newId);
        this.registeredClients.set(clientId, newClient);
    }

    getClientServiceId(clientId: string): string | null {
        const serviceId = this.registeredClients.get(clientId)?.id;

        if(serviceId == null) return null;
        
        return serviceId;
    }

    getClientService(clientId: number): CameraClientService | null {
        return  this.registeredClients[clientId];
    }

    removeClientServiceId(clientId: string): void {
        this.registeredClients.delete(clientId);
        this.clientCount--;
    }
}