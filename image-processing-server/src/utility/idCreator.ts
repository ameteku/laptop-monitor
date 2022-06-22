export default class IdCreator{
    private existingIds: Set<string>;
    constructor() {
        this.existingIds = new Set();
    }

    generateId() {
        const success = false;
        while(!success) {
            const tempId = (Date.now() * Math.random() * 10).toString();
            if(!this.existingIds.has(tempId)) {
                this.existingIds.add(tempId);
                return tempId;
            }
        }
    }
}