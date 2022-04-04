import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import type dbConstants from '../constants/dbConstants';
import { Result } from '../models/videoResultsContainer';

export default class DBConnector {
    static db: FirebaseFirestore.Firestore;

    constructor() {

        if(DBConnector.db === undefined) {
            DBConnector.db = getFirestore();
        }
       
    }

    get database():FirebaseFirestore.Firestore  {
        return DBConnector.db;
    }

   async addDocument(params : { doc :{[key: string]: any} , collectionPath: dbConstants, docId: string  }) : Promise<boolean> {
        return await DBConnector.db.collection(params.collectionPath).doc(params.docId).set(params.doc).
                catch (error=> {
                    console.log("error setting new doc ", error);
                       return false;
                    }
                ).then(()=> {
                    return true;
                });
    }

    async getCollection(collectionPath: dbConstants, docId: string): Promise<object> {
        return DBConnector.db.collection(collectionPath).get().
        then(result => {
            if(result.docs.length === 0) return null;
            return result.docs.map(item => item.data());
        });
    }

    async removeDocument(params : { docId :string,  collectionPath: dbConstants }) : Promise<boolean> {
        return await DBConnector.db.collection(params.collectionPath).doc(params.docId).delete().then(result => true).catch(error => {
            console.log("Error in removing doc", error);
            return false;
        });
    }

    // todo : add check for key against objects eg. Class, user
    async updateDoc(params: {json : {[key: string] : any} ,docId: string, collectionPath: dbConstants}) : Promise<boolean> {
        return await DBConnector.db.collection(params.collectionPath).doc(params.docId).update(params.json).then(result => {
            return true;
        }).catch(error => {
            console.log("Update was not successful, trying to create new doc" + error);

            return this.addDocument({
                doc: params.json,
                collectionPath: params.collectionPath,
                docId: params.docId
            }).catch(error => {
                console.log("Could not create new doc also with error", error );
                return false;
            });
        })
    }
}


