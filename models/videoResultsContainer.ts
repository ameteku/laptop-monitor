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

    //removes the last image and return
    get popQueue(): Array<number> {
        let tempImageData;
        tempImageData = this.resultQueue.pop();
        this.count--;
        
        return tempImageData;
    }
}

export type Result = {
    containsHuman?: boolean;
    distanceFromCamera?: number ;
}