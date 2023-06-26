## iOS Assessment | Albert Heijn

### Overview
The aim of this project is to develop an iOS application to search and display the list of art objects in Rijksmuseum. 

### Features
This app has a couple of screens with the following features,

#### Museum collections list search screen - This screen allows users to search and view the art objects by keywords associated with them

![Simulator Screen Shot - iPhone 14 Pro - 2023-06-26 at 09 05 12](https://github.com/jayesh15111988/RijksmuseumCollections/assets/6687735/479f4474-cbb8-43a4-879c-4bd37d63e45f)


#### Museum collections details screen - This screen allows users to view extra details about selected art objects.  This includes extended title, location of creation, large image, and artists associated with the work


![Simulator Screen Shot - iPhone 14 Pro - 2023-06-26 at 09 05 15](https://github.com/jayesh15111988/RijksmuseumCollections/assets/6687735/f05f7776-8142-430c-8552-8ddcbddde01a)

### Architecture
The app uses MVVM architecture. The reason is, I wanted to separate out all the business and data transformation logic away from the view layer. 
The view model is responsible for getting network models (Decodable models) from network service and converting them into local view models to be consumed by the view layer.

The view model interacts with the network layer through protocols and gets the required data with network calls via interfaces.

I ruled out MVC due to it polluting the view layer and making it difficult to just test the business logic due to intermixing with a view. 
I also thought about VIPER architecture, but it seemed an overkill for a feature this small given the boilerplate code it tends to add. 
Finally, I decided to use MVVM as a middle ground between these two possible alternatives.

### How to run the app?
The app can be run simply by opening "RijksmuseumCollections.xcodeproj" file and pressing CMD + R to run it

### Unit Tests
I have written unit tests to test the view model layer and view layer (Such as section header and collection view cells) wherever applicable. 
Tests are written with the mindset to test the business logic and also configuring view layer with the provided view models. That way, we can catch bugs in business logic
as well as during applying those view models to layers. Not everything can be tested in either UI or Unit tests, so I tried to write them in such a way that they complement and
overlap each other in certain areas. No tests are written for the coordinator layer. They're covered in UI tests.

### UI/Automated tests
I have also added UI tests to test the flow between various pages. Tests are added to verify the existance and value of static elements and make sure 
the app can navigate between the list and details screen.

In cases where dynamic data is loaded, I am checking the existence of those UI elements to make sure they do exist or not depending on the current state of app. UI Tests are added
in separate `RijksmuseumCollectionsUITests` target. Right now, the app loads data during UI tests from the actual endpoint. As a future enhancement, changes could be 
made to use a separate endpoint when UI tests are running to make tests more deterministic.

### Test Coverage
The app has a total test coverage of 93%

### Device support
This app is currently supported only on iPhone (Any model) in portrait mode.

### Handling of failures
The app is designed to handle any kind of failure originating from network request handling. 
Besides this, I have also added appropriate user-facing messages in case no input is provided or no art objects are found for the given keyword. 

In case a network request fails, the user can also retry the previous request. This acts as protection against one-off failures and network glitches.

### Styles and Designs
I have used very minimal styles and designs but still kept things consistent across screens. I decided to instead focus on architecture, error handling, and testable app 
design instead of adding fancy UI. However, that shouldn't be an issue if we want to enhance design in the future. The way the app is set up, it is very easy to centralize
all the style elements and apply them throughout the app.

### Third-party images used
I am using only one third-party image as a placeholder in case the image cannot be downloaded or the remote URL does not exist. Other than this, app does not use any third-party images. 
All the other images you may see in the app directly come from Rijksmuseum API and are downloaded from this source.

### Usage of 3rd party library
I am not using any 3rd party library in this app.

### Deployment Target
The app needs a minimum version of iOS 13 for the deployment

### Xcode version
The app was compiled and run on Xcode version 14.2

### API used
I am using official [Rijksmuseum API](https://data.rijksmuseum.nl/object-metadata/api/) to find and retrieve art objects by search keyword.

### Future enhancements
The project can be extended in several ways in the future

- Showing the list of previously searched keywords when a user taps into the search field
- Adding styles and better UI
- Using a dedicated endpoint for UI testing
- Accessibility

### Swift version used
Swift 5.0
