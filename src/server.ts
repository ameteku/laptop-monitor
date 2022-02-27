import express from 'express';
import cors from "cors";
import ClientRegister from './ClientRegister/ClientRegister';

const app = express();
const clientRegister = new ClientRegister();

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
    // console.log("Called");
    // const body = req.body;
    // const imageData = JSON.parse(body["imageData"]);
    // console.log(imageData[0]);
    // res.send("Success");

    //get data, then validate, then pass on to clientDelegate to store and call for start to process.
    //send success response
})

app.post("/getResults", (req, res) => {
    res.send("coming soon");
})

app.listen(3000, () => {
    console.log("listening on 3000");
});