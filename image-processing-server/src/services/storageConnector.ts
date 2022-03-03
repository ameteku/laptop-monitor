import { getStorage } from "firebase-admin/storage";
import { initializeApp, cert } from 'firebase-admin/app';
import { Bucket } from "@google-cloud/storage";

export default class StorageConnector {
    static storage: Bucket;

    constructor() {
        const serviceAccount = require('../../lapnitor-firebase-adminsdk-trb25-09a07e1d3d.json');

        // initializeApp({
        //     credential: cert(serviceAccount),
        //     storageBucket: "gs://lapnitor.appspot.com"
        // });

        if(StorageConnector.storage === undefined) {
           StorageConnector.storage = getStorage().bucket();
        }
       
    }

    get storage(): Bucket  {
        return StorageConnector.storage;
    }

   async addFile(params : {filePath?: string,  dbPath: string  }) : Promise<string | null> {
       let filePath = params.filePath;
       if(filePath == undefined ) {
            return null;
       }

    const destinationPath = params.dbPath + "-" + params.filePath;
       return await  StorageConnector.storage.upload(params.filePath, {
            destination: destinationPath
        }).then(e=> {
            return destinationPath;
        }).catch(error=> {
            console.log("An error occurred whilst uploading")
            return null;
        });
    }

    // async getCollection(collectionPath: storageConstants, docId: string): Promise<object> {
    //     return StorageConnector.storage.collection(collectionPath).get().
    //     then(result => {
    //         if(result.docs.length === 0) return null;
    //         return result.docs.map(item => item.data());
    //     });
    // }

    // async removeFile(params : { docId :string,  collectionPath: storageConstants }) : Promise<boolean> {
    //     return await StorageConnector.storage.collection(params.collectionPath).doc(params.docId).delete().then(result => true).catch(error => {
    //         console.log("Error in removing doc", error);
    //         return false;
    //     });
    // }

    // todo : add check for key against objects eg. Class, user
    // async updateFile(params: {json : {[key: string] : any} ,docId: string, collectionPath: storageConstants}) : Promise<boolean> {
    //     return await StorageConnector.storage.collection(params.collectionPath).doc(params.docId).update(params.json).then(result => {
    //         return true;
    //     }).catch(error => {
    //         console.log("Update was not successful, trying to create new doc" + error);

    //         return this.addFile({
    //             doc: params.json,
    //             collectionPath: params.collectionPath,
    //             docId: params.docId
    //         }).catch(error => {
    //             console.log("Could not create new doc also with error", error );
    //             return false;
    //         });
    //     })
    // }
}


