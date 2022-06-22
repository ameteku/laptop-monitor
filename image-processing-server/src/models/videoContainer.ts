export default class VideoContainer {
    private count: number;
    private ImageQueue: Array<videoFrame>;
    constructor() {
        this.ImageQueue = [];
        this.count = 0;

    }
 
    //image list is a list of uInt8List
    appendImages(imageData:Array<videoFrame> ) {
            if(imageData.length == 0) {
                throw "EmptyFrames";
            }

            this.ImageQueue.push(...imageData);
            this.count += imageData.length;
    }

    //removes the last image and return
get popQueue(): videoFrame | null {

        if(this.count > 0) {
            const tempImageData = this.ImageQueue.shift();
            this.count--;

            return tempImageData;
        }
    }
}



export type videoFrame = Array<number>;