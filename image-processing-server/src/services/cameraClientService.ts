import VideoContainer, { videoFrame } from "../models/videoContainer";
import VideoResultsContainer, { Result } from "../models/videoResultsContainer";
import DBConnector from "./dbConnector";

export default class CameraClientService {
    private videoContainer: VideoContainer;
    private videoResults: VideoResultsContainer;
    private db: DBConnector;

    id: string;
    static dangerDistance = 5;

    constructor(id: string) {
        this.videoContainer = new VideoContainer();
        this.videoResults = new VideoResultsContainer();
        this.db = new DBConnector();

        this.id = id;
    }

    addVideoFeed(feed: Array<videoFrame>): void {
        if(feed.length === 0) {
            return;
        }

        this.videoContainer.appendImages(feed);
    }

    async processFrames(): Promise<void> {
         //start by getting a frame
        let frame = this.videoContainer.popQueue;

        while(frame != null) {

            //run frame through nn

            //get results and appedn
            const result: Result = {
                containsHuman : true,
                distanceFromCamera: Math.random() * 10,
                timestamp:new  Date()
            }

            if( result.containsHuman && result.distanceFromCamera < CameraClientService.dangerDistance){
                this.videoResults.appendResult(result);

                const docTimeStamp = result.timestamp;
                const dbDocId = this.id + "-" + docTimeStamp.getFullYear() +'-' + docTimeStamp.getMonth() + '-' + docTimeStamp.getDay();

                const resultKey = result.timestamp.getTime();
                const jsonData = {
                    [resultKey] : result
                }
                
                await this.db.updateDoc({
                    json: jsonData,
                    docId: dbDocId,
                    collectionPath: "userResults"
                });
            }
            
            frame = this.videoContainer.popQueue;

        }
        console.log('Done processing with: ', this.videoResults.totalResultsCount);
    }

    getResults(): Array<Result>  {
        return this.videoResults.allResults;
    }

}