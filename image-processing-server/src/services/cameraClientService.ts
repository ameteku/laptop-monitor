import VideoContainer, { videoFrame } from "../models/videoContainer";
import VideoResultsContainer, { Result } from "../models/videoResultsContainer";
import DBConnector from "./dbConnector";
import StorageConnector from "./storageConnector";
import fs from "fs";

export default class CameraClientService {
    private videoContainer: VideoContainer;
    private videoResults: VideoResultsContainer;
    private db: DBConnector;
    private fileStorage: StorageConnector;

    id: string;
    clientId: string;
    static dangerDistance = 5;

    constructor(id: string, clientId: string) {
        this.videoContainer = new VideoContainer();
        this.videoResults = new VideoResultsContainer();
        this.db = new DBConnector();
        this.fileStorage = new StorageConnector();

        this.clientId = clientId;
        this.id = id;
    }

    addVideoFeed(feed: Array<videoFrame>): void {
        if (feed.length === 0) {
            return;
        }

        this.videoContainer.appendImages(feed);
    }

    async processFrames(): Promise<void> {
        //start by getting a frame
        let frame = this.videoContainer.popQueue;

        while (frame != null) {

            //run frame through nn

            //get results and appedn
            const result: Result = {
                containsHuman: true,
                distanceFromCamera: Math.random() * 10,
                timestamp: new Date(),
            }

            if (result.containsHuman && result.distanceFromCamera < CameraClientService.dangerDistance) {
                // this.videoResults.appendResult(result);
                const buffer = new Buffer(frame)
                const newFilePath = `potential-threat-${result.timestamp}.png`;
                fs.writeFileSync(newFilePath, buffer);
                const cloudPath = await this.fileStorage.addFile({
                    filePath: newFilePath,
                    dbPath: `${this.clientId}/${newFilePath}`
                });

                result.imageLink = cloudPath;
                this.uploadToDB(result);
            }

            frame = this.videoContainer.popQueue;

        }
        console.log('Done processing with: ', this.videoResults.totalResultsCount);
    }

    private async uploadToDB(result: Result): Promise<void> {
        const docTimeStamp = result.timestamp;
        const dbDocId = this.clientId + "-" + docTimeStamp.getFullYear() + '-' + docTimeStamp.getMonth() + '-' + docTimeStamp.getDay();

        const resultKey = result.timestamp.getTime();
        const jsonData = {
            [resultKey]: result
        }

        //using updateDoc in order to avoid creating duplicate docs - contains addNew doc is doc does not already exist.
        await this.db.updateDoc({
            json: jsonData,
            docId: dbDocId,
            collectionPath: "userResults"
        });
    }

    getResults(): Array<Result> {
        return this.videoResults.allResults;
    }

}