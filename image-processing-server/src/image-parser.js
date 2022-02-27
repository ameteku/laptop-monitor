ImageBuffer = require("./models/videoContainer");
imageResult= {
    data : [],
    result : false
}

class ImageParser { 

    constructor () {
        this.startProcessing = false;
        this.imageBuffer = ImageBuffer();
    }

    startProcessingImage() {
        this.startProcessing = true;
        var currentImage
        while(this.startProcessing) {
           currentImage =  this.imageBuffer.popQueue();

           if(currentImage != null) {
               //process image
               console.log("processing current image: ");
               console.table(currentImage);
           }
           else {
               console.log("current image is empty");
           }
        }
    }


    stopProcessing() {
        this.startProcessing = false;
    }


}