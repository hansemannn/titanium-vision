var Vision = require('ti.vision');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn = Ti.UI.createButton({
    title: 'Recognize Image Rectangles'
});

btn.addEventListener('click', function() {
    if (!Vision.isSupported()) {
        return Ti.API.error('Sorry dude, iOS 11+ only!');
    }
    
    Vision.detectTextRectangles({
        image: 'image_sample_tr.png',
        callback: function(e) {
            if (!e.success) {
                return Ti.API.error(e.error);
            }
            
            Ti.API.info(e);
        }
    });
});

win.add(btn);
win.open();
