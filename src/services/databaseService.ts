import { initializeApp, applicationDefault, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp, FieldValue } from 'firebase-admin/firestore';
import type dbConstants from '../constants/dbConstants';
import { Result } from '../models/videoResultsContainer';

export default class DBConnector {
    private db: FirebaseFirestore.Firestore;

    constructor() {
        const serviceAccount = require('../../lapnitor-firebase-adminsdk-trb25-09a07e1d3d.json');

        initializeApp({
            credential: cert(serviceAccount)
        });
        this.db = getFirestore();
    }

    get database():FirebaseFirestore.Firestore  {
        return this.db;
    }

   async addDocument(params : { doc :Result , collectionPath: dbConstants, docId: string  }) : Promise<boolean> {
        return await this.db.collection(params.collectionPath).doc(params.docId).set(params.doc).
                catch (()=> {
                       return false;
                    }
                ).then(()=> {
                    return true;
                });
    }

    async getCollection(collectionPath: dbConstants, docId: string): Promise<object> {
        return this.db.collection(collectionPath).get().
        then(result => {
            if(result.docs.length === 0) return null;
            return result.docs.map(item => item.data());
        });
    }

    async removeDocument(params : { docId :string,  collectionPath: dbConstants }) : Promise<boolean> {
        return await this.db.collection(params.collectionPath).doc(params.docId).delete().then(result => true).catch(error => {
            console.log("Error in removing doc", error);
            return false;
        });
    }

    // todo : add check for key against objects eg. Class, user
    async updateDoc(params: {json : {} ,docId: string, collectionPath: dbConstants}) : Promise<boolean> {
        return await this.db.collection(params.collectionPath).doc(params.docId).update(params.json).then(result => {
            return true;
        }).catch(error => {
            console.log("Update error occured" + error);
            return false;
        })
    }
}

