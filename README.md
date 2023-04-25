# iOS Vision / VisionKit in Titanium
Use the native "Vision" and "VisionKit" frameworks in Titanium!

| Original image | Processed image |
|----------------|-------------------|
| <img src="./screens/vision-before.PNG" width="300" alt="Before" /> | <img src="./screens/vision-after.PNG" width="300" alt="After" /> |

## Requirements
- [x] Titanium SDK 10.0.0 or later

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

#### `detectRectangles(args)`
- `image` (String | Ti.Blob - _Required_)
- `minimumAspectRatio` (Number - default 0.5)
- `maximumAspectRatio` (Number - default 1.0)
- `quadratureTolerance` (Number - default 30)
- `minimumSize`:  (Number - default 0.2)
- `maximumObservations`:  (Number - default 1)
- `callback` (Function - _Required_)

### Examples

#### detectTextRectangles

```js
import Vision from 'ti.vision';

const win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

const btn = Ti.UI.createButton({
    title: 'Recognize Image Rectangles'
});

btn.addEventListener('click', () => {
    if (!Vision.isSupported()) {
        Ti.API.error('Sorry dude, iOS 11+ only!');
        return;
    }
    
    Vision.detectTextRectangles({
        image: 'image_sample_tr.png',
        callback: event => {
            if (!event.success) {
                Ti.API.error(event.error);
                return;
            }
            
            Ti.API.info(event);
        }
    });
});

win.add(btn);
win.open();
```

#### detectRectangles

```js
import Vision from 'ti.vision';

const win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

const btn = Ti.UI.createButton({
    title: 'Recognize Image Rectangles'
});

btn.addEventListener('click', () => {
    if (!Vision.isSupported()) {
        Ti.API.error('Sorry dude, iOS 11+ only!');
        return;
    }
    
    Vision.detectRectangles({
            image: 'image_sample.png',
            minimumAspectRatio: 0.5,
            maximumAspectRatio: 1.0,
            quadratureTolerance: 20,
            minimumSize: 0.2,
            maximumObservations: 1,
            callback: event => {
                if (!event.success) {
                    Ti.API.error(event.error);
                    return;
                }

                Ti.API.info(event);
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
