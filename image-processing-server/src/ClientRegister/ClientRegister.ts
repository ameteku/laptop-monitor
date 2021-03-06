import CameraClientService from "../services/cameraClientService";
import DBConnector from "../services/dbConnector";
import IdCreator from "../utility/idCreator";

export default class ClientRegister {

    
    private idCreator: IdCreator;
//this contains a map of clientId to clientServiceInstanceId
    private registeredClients: Map<string, CameraClientService>;
    private totalLifetimeClientsAdded = 0;
    public clientCount = 0;
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

        const newClient = new CameraClientService(newId,clientId);
        this.registeredClients.set(clientId, newClient);
    }

    private getClientServiceId(clientId: string): string | null {
        const serviceId = this.registeredClients.get(clientId)?.id;

        if(serviceId == null) return null;

        return serviceId;
    }

    getClientService(clientId: string): CameraClientService | null {
        return  this.registeredClients.get(clientId);
    }

    private removeClientServiceId(clientId: string): void {
        this.registeredClients.delete(clientId);
        this.clientCount--;
    }
}