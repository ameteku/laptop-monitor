const express = require('express');
const cors = require("cors");

const app = express();
app.use(cors())

app.use(express.json({limit : '50mb'}))
app.use(express.urlencoded({
    limit : '50mb',
    extended: true,
    parameterLimit: 50000
}));


app.post("/image-batch", (req, res)=> {
    console.log("Called");
    body = req.body;
    imageData = JSON.parse(body["imageData"]);
    console.log(imageData[0]);
res.send("Success");
})


app.listen(3000,()=> {
    console.log("listening on 3000");
});