export default class VideoResultsContainer {
    private resultQueue: Array<Result>;
    private count: number;

    constructor() {
        this.resultQueue = [];
        this.count = 0;

    }

    //image list is a list of uInt8List
    appendResult(result: Result ) {
            this.resultQueue.push(result);
            this.count++;
            console.log("Added result to list" + this.resultQueue);
    }
    get totalResultsCount() {
        return this.count;
    }

    //removes the last image and return
    get popQueue(): Result {
        const tempImageData =  this.resultQueue.shift();
        this.count--;
        
        return tempImageData;
    }

    //todo: check for any race conditions with appending new results
    get allResults(): Array<Result> {
        const allData = [...this.resultQueue];
        this.count = 0;

        //clearing all gotten data
        this.resultQueue.length = 0;

        return allData;
    }
}

export type Result = {
    containsHuman?: boolean;
    distanceFromCamera?: number;
    timestamp?: Date;
    imageLink?: string;
}