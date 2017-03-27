# ChooseYourDestiny
Capstone project for iOS Nanodegree from Udacity

Features:
* Swift 3 (updated from Swift 2.1)
* Multiple Views
* Interracts with a Web Service
* Uses CoreData

Description:
This is a "multiple choice"-type story reading app. The story content is open to any author and is hosted on GitHub. A author must do three things to get their story listed in this app:
* create a GitHub repo with a README.md containing #ChooseYourDestiny
* create a story.json file in the root of the repo in the format at https://github.com/jonathandgrubb/PrototypeStory/blob/master/story.json
* request the addition of their GitHub username to the "author's file" at https://github.com/jonathandgrubb/ChooseYourDestiny-authors/blob/master/authors.json

The reader itself contains a TabView Controller that displays both downloaded and available content on GitHub. A search bar further narrows these results for manageability. A swipe to the left also offers the ability to Delete a story from the device. Stories' text and choices for the next chapter are persisted immediately to local storage via CoreData while pictures are lazy loaded (on demand). The pictures themselves are either stored on GitHub as a story "resource" or are hyperlinks to pictures on the web. 

Starting the app will prompt the user via a modal view to enter their first name if it has never been entered. It will be used to replace [[name]] fields used by the story author (ex. 'High Seas'). Next, in the Stories tab, the app will access the downloaded titles and refresh the list of GitHub titles into a TableView. Clicking an 'available' title will download it to the device. Clicking a 'downloaded' title will start the story in the Reading Tab. 

The Reading tab is comprised of the current chapter of the story. The chapters are rendered into a view constructed of a UIImageView (chapter pic - optional), UITextView (chapter text), and TableView (choices for the next chapter - optional), embedded in a StackView, embedded in a ScrollView. Segues to the next chapter use the same ViewController. Loading a new story will pop the NavigationController stack and load chapter 1 of the new story.

Future Plans:
* remember where the reader is in the story for continuing reading
* optional video in a chapter instead of a picture
* story creator / editor / sharing 

