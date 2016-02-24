# GEImagePicker
Easy image picker - Closure callback with status - Permission Check - Action Sheet tool

You can easily pick a picture from your Camera, Album or Library in one call and a **closure as response** with the picture selected and the final status. You can also decide if you want to let the user crop the picture or not (**editMode**).

In addition this tool will check the **permissions** the app has for accessing to the Camera or Library and it will let you go to the application settings panel in order to get them activated.

It was added an **actionsheet** for making easier the selection of the picture.

![ActionSheet](Resources/action_sheet.png=100x20)

## Usage
If you want to try the example project clone the repository and run pod install from the Example directory first.

To use it in your own project

* Directly setting the source:

```swift
// In this case we are going to pick a picture from PhotoLibrary and
// I will be able to crop it because I set the editMode to true

GEImagePicker.pickImage(GEImagePickerSource.PhotoLibrary, whereViewController: self, editMode: true) { (image, status) -> () in
            
            switch status {
                case GEImagePickerStatus.Cancelled:
                    print("Cancelled")
                break
                case GEImagePickerStatus.NoSource:
                    print("No source")
                break
                case GEImagePickerStatus.NotPermission:
                    print("No permissions")
                break
                case GEImagePickerStatus.OK:
                    print("OK")
                break
                
            }
}
```

* Throughout the action sheet tool

```swift
GEImagePicker.pickImageActionSheet(self, editMode: true) { (image, status) -> () in
            
            switch status {
                
            case GEImagePickerStatus.Cancelled:
                print("Cancelled")
                break
            case GEImagePickerStatus.NoSource:
                print("No source")
                break
            case GEImagePickerStatus.NotPermission:
                print("No permissions")
                break
            case GEImagePickerStatus.OK:
                print("OK")
                break
                
            }
}

```

## Info
* We can receive several status from the callback:

```swift
enum GEImagePickerStatus {
    case OK
    case Cancelled
    case NoSource
    case NotPermission
}
```

* In addition you can select the source for picking the picture

```swift
enum GEImagePickerSource {
    case Camera
    case SavedPhotosAlbum
    case PhotoLibrary
}
```


## Requirements

iOS 8.0

## Installation
Copy GEImagePicker.swift file to your project and add the import line:

```swift
import GEImagePicker
```
## Author

Miguel Rodríguez, www.geitoo.com

## License

GEImagePicker is available under the MIT license. See the LICENSE file for more info.
