export default class VideoResultsContainer {
    private count: number;
    private resultQueue: Array<Result>;
    constructor() {
        this.resultQueue = [];
        this.count = 0;

    }

    //image list is a list of uInt8List
    private appendResult(result: Result ) {
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

export type ActivityType = "HumanDetected" | "LaptopMoved";
export type Result = {
    activityType?: ActivityType;
    distanceFromCamera?: number;
    timestamp?: Date;
    imageLink?: string;
}