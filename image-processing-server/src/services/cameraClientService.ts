import VideoContainer, { videoFrame } from "../models/videoContainer";
import VideoResultsContainer, { Result } from "../models/videoResultsContainer";
import DBConnector from "./dbConnector";
import StorageConnector from "./storageConnector";
import fs from "fs";
import '@tensorflow/tfjs-backend-cpu';
import '@tensorflow/tfjs-backend-webgl';
import * as CocoSsd from "@tensorflow-models/coco-ssd";
import { Tensor3D } from "@tensorflow/tfjs-core";
import * as tf from '@tensorflow/tfjs-node'


export default class CameraClientService {
    private videoContainer: VideoContainer;
    private videoResults: VideoResultsContainer;
    private db: DBConnector;
    private fileStorage: StorageConnector;
    private bodyDetector: CocoSsd.ObjectDetection;

    id: string;

    clientId: string;
    static dangerDistance = 5;

    constructor(id: string, clientId: string) {
        // global.Image = new Canvas.Image()
        this.videoContainer = new VideoContainer();
        this.videoResults = new VideoResultsContainer();
        this.db = new DBConnector();
        this.fileStorage = new StorageConnector();
        this.clientId = clientId;
        this.id = id;

        this.createServiceDBDoc().then(result =>
            console.log(result ? "Successfully created service doc" : "Failed to create service doc")
        );
    }

    async addVideoFeed(feed: Array<videoFrame>) {
        if (!this.bodyDetector) {
            this.bodyDetector = await CocoSsd.load();
        }

        if (feed.length === 0) {
            return;
        }

        this.videoContainer.appendImages(feed);

    }

    async processFrames(): Promise<void> {
        //start by getting a frame
        let frame = this.videoContainer.popQueue;

        while (frame != null) {

            //create image buffer
            const tempImageBuffer = new Buffer(frame);
            const newImageTensor = tf.node.decodeImage(tempImageBuffer, 3);

            const itemsDetected = await this.bodyDetector.detect(newImageTensor as Tensor3D, 1);
            console.log("nn said: ", itemsDetected);

            const humanDetected = itemsDetected.reduce((prev, current) => {
                if (current.class == "person") {
                    return current;
                }
                return prev;
            });

            //todo: add distance detection

            if (humanDetected.class === "person" && 4 < CameraClientService.dangerDistance) {
                // this.videoResults.appendResult(result);

                //create result object
                const result: Result = {
                    activityType: "HumanDetected",
                    distanceFromCamera: Math.random() * 10,
                    timestamp: new Date(),
                }

                const newFileName = `potential-threat-${result.timestamp}.png`;
                const tempFileName = "temp.png";
                fs.writeFileSync(tempFileName, tempImageBuffer)

                const cloudPath = await this.fileStorage.addFile({
                    filePath: tempFileName,
                    fileName : newFileName,
                    dbPath: `${this.clientId}/`
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
        const dbDocId = docTimeStamp.toISOString();

        const resultKey = result.timestamp.getTime();
        const jsonData = result;


        //using updateDoc in order to avoid creating duplicate docs - contains addNew doc is doc does not already exist.
        await this.db.updateDoc({
            json: jsonData,
            docId: dbDocId,
            collectionPath: "userResults" + `/${this.clientId}/suspectImages`
        });
    }

    getResults(): Array<Result> {
        return this.videoResults.allResults;
    }

    private async createServiceDBDoc(): Promise<boolean> {
        return this.db.addDocument({
            doc: { "id": this.clientId },
            collectionPath: "userResults",
            docId: this.clientId
        });

    }
}