import express from 'express';
import cors from "cors";
import { initializeApp, cert } from 'firebase-admin/app';
import ClientDataDelegate from '../services/clientDataDelegate';
import ClientRegister from '../ClientRegister/ClientRegister';



export default class MainApp {
    private app = express();
    private clientDelegate: ClientDataDelegate;
    private clientRegister: ClientRegister;
    private static  readonly  PORT:number | String  = process.env.PORT || 3000;
    
    constructor() {
        const serviceAccount = require('../../lapnitor-firebase-adminsdk-trb25-09a07e1d3d.json');

        initializeApp({
            credential: cert(serviceAccount),
            storageBucket: "gs://lapnitor.appspot.com"
        });

        this.app.use(cors())
        this.app.use(express.json({ limit: '50mb' }))
        this.app.use(express.urlencoded({
            limit: '50mb',
            extended: true,
            parameterLimit: 50000
        }));

        this.clientRegister = new ClientRegister();
        this.clientDelegate = new ClientDataDelegate(this.clientRegister);
    }
     
    getHome() {
        return this.app.get("/", (req, res) => {
            res.send("Hellooo");
        })
    }

    getConnectEntryPoint = () => {
        return this.app.post("/connect", (req, res) => {
            const ip = (req.headers['x-forwarded-for'] || req.connection.remoteAddress).toString();
            console.log(ip); // ip address of the user
            if (!this.clientRegister.isRegisteredClient(ip)) {
                this.clientRegister.addClientService(ip);
                res.status(200).send({
                    id: ip
                });
            }
        
            res.status(200).send({
                message: "already registered",
                id: ip
            });
        });
    }

    getAddVideoFeedEndpoint() {
        return this.app.post("/addVideoFeed", async (req, res) => {
            console.log("Called");
            try {
                const body = req.body;
        
                //get data, then validate, then pass on to clientDelegate to store and call for start to process.
                if (!body.frames || !body.id) {
                    res.status(403).send({
                        result: false,
                        message: "empty field"
                    });
                }
        
                const isSuccessful = await this.clientDelegate.addVideo(body.id, JSON.parse(body.frames));
                if (isSuccessful) {
                    res.status(200).send(true);
                }
                else {
                    res.status(503).send({
                        result: false,
                        message: "failed to add"
                    });
                }
            }
            catch (error) {
                console.log(error);
                res.status(500).send({
                    result: false,
                    messsage: `Failed with: ${error}`
                });
            }
        });
    }

    getResults() {
        return this.app.get("/getResults", (req, res) => {
            const id = req.query.id.toString();
            console.log("Id is", id);
            if (id == null || id === "") {
                res.status(403).send({
                    result: false,
                    message: "please append your id to url"
                });
            }
        
            try {
                const results = this.clientDelegate.getResults(id);
                res.status(200).send({
                    processedResults: results
                });
            }
            catch (error) {
                res.status(500).send({
                    result: false,
                    messsage: `Failed with: ${error}`
                });
            }
        
        });
    }

    listen() {
        return this.app.listen(MainApp.PORT, () => {
            console.log("listening on 3000");
        });
    }
}