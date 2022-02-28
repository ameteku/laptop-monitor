import express from 'express';
import cors from "cors";
import ClientRegister from './ClientRegister/ClientRegister';
import ClientDataDelegate from './services/clientDataDelegate';
import { videoFrame } from './models/videoContainer';

const app = express();
const clientRegister = new ClientRegister();
const clientDelegate = new ClientDataDelegate(clientRegister);
app.use(cors())

app.use(express.json({ limit: '50mb' }))
app.use(express.urlencoded({
    limit: '50mb',
    extended: true,
    parameterLimit: 50000
}));

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

app.post("/addVideoFeed", (req, res) => {
    console.log("Called");
    try {
        console.log(req.body);
        const body = req.body;
       
        //get data, then validate, then pass on to clientDelegate to store and call for start to process.
        if (body.frames === null || body.frames === undefined || body.id == null || body.id == undefined) {
            res.status(503).send({
                result: false,
                message: "empty field"
            });
        }

        const isSuccessful = clientDelegate.addVideo(body.id, body.frames);
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
        res.status(500).send({
            result: false,
            messsage: `Failed with: ${error}`
        });
    }
});

app.post("/getResults", (req, res) => {
    res.send("coming soon");

})

app.listen(3000, () => {
    console.log("listening on 3000");
});