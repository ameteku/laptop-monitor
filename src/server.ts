import express from 'express';
import cors from "cors";
import ClientRegister from './ClientRegister/ClientRegister';
import ClientDataDelegate from './services/clientDataDelegate';
import { videoFrame } from './models/videoContainer';
import { initializeApp, cert } from 'firebase-admin/app';

const app = express();
app.use(cors())

app.use(express.json({ limit: '50mb' }))
app.use(express.urlencoded({
    limit: '50mb',
    extended: true,
    parameterLimit: 50000
}));

const serviceAccount = require('../lapnitor-firebase-adminsdk-trb25-09a07e1d3d.json');

initializeApp({
    credential: cert(serviceAccount),
    storageBucket: "gs://lapnitor.appspot.com"
});

const clientRegister = new ClientRegister();
const clientDelegate = new ClientDataDelegate(clientRegister);

app.post("/connect", (req, res) => {
    const ip = (req.headers['x-forwarded-for'] || req.connection.remoteAddress).toString();
    console.log(ip); // ip address of the user
    if (!clientRegister.isRegisteredClient(ip)) {
        clientRegister.addClientService(ip);

        res.status(200).send({
            id: ip
        });
    }

    res.status(200).send({
        message: "already registered",
        id: ip
    });
});

app.post("/addVideoFeed", async (req, res) => {
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

        const isSuccessful = await clientDelegate.addVideo(body.id, JSON.parse(body.frames));
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

app.get("/getResults", (req, res) => {
    const id = req.query.id.toString();
    console.log("Id is", id);
    if (id == null || id === "") {
        res.status(403).send({
            result: false,
            message: "please append your id to url"
        });
    }

    try {
        const results = clientDelegate.getResults(id);
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

})

app.listen(3000, () => {
    console.log("listening on 3000");
});