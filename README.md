# iOS 11+ Vision in Titanium
Use the native iOS 11+ "Vision" framework in Axway Titanium. Also includes iOS 13+ "VisionKit" API's.

| Original image | Processed image |
|----------------|-------------------|
| <img src="./screens/vision-before.PNG" width="300" alt="Before" /> | <img src="./screens/vision-after.PNG" width="300" alt="After" /> |

## Requirements
- [x] Titanium SDK 8.2.0 or later

## API's

### Methods

#### `detectTextRectangles(args)`
- `image` (String | Ti.Blob - _Required_)
- `callback` (Function - _Required_)
- `reportCharacterBoxes` (Boolean - _Optional_)
- `regionOfInterest` (Object(x, y, width, height) - _Optional_)

#### `detectFaceRectangles(args)`
- `image` (String | Ti.Blob - _Required_)
- `callback` (Function - _Required_)
- `regionOfInterest` (Object(x, y, width, height) - _Optional_)

#### `recognizeText(args)`
- `image` (String | Ti.Blob - _Required_)
- `callback` (Function - _Required_)
- `customWords` (Array<String> - _Optional_)
- `recognitionLanguages` (Array<String> - _Optional_)
- `usesLanguageCorrection` (Boolean - _Optional_)

## Example
```js
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
```

## Build
```js
ti build -p ios --build-only
```

## Author

Hans Knöchel

## License

Apache 2.0
