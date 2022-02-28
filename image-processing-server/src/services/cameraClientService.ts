import VideoContainer, { videoFrame } from "../models/videoContainer";
import VideoResultsContainer, { Result } from "../models/videoResultsContainer";

export default class CameraClientService {
    private videoContainer: VideoContainer;
    private videoResults: VideoResultsContainer;
    id: string;
    static dangerDistance = 1;

    constructor(id: string) {
        this.videoContainer = new VideoContainer();
        this.videoResults = new VideoResultsContainer();
        this.id = id;
    }

    addVideoFeed(feed: Array<videoFrame>): void {
        if(feed.length ==0) {
            return;
        }

        this.videoContainer.appendImages(feed);
    }

    processFrames(): void {
         //start by getting a frame
        let frame = this.videoContainer.popQueue;

        while(frame != null) {

            //run frame through nn

            //get results and appedn
            const result: Result = {
                containsHuman : true,
                distanceFromCamera: 10
            }
            this.videoResults.appendResult(result);
        }
    }

    processResult(): void {

    }

    getResults(): Array<Result>  {
        return [];
    }

}