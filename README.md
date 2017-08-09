# README #

Stock Test App

### What is this repository for? ###

* Holds the project code for Stock Test App
* Version 1.0

### How do I get set up? ###

* Clone project onto Mac that has Xcode v8 installed
* Open "StockTestApp.xcworkspace" from project
* Run project in iOS 9+ simulator/device

### Project Details ###

#### Code Implementation ####
* Built in Swift 3
* Stores data in keychain
* Logs user in with facebook
* Supports iOS 9+
* Tested in iPhone, but supports iPad
* Supports landscape and portrait

#### Open Source Dependencies ####
* Alamofire
* FacebookCore
* FacebookLogin
* CSwiftV

### App Overview ###

#### Login Page ####
* Login page simply allows user to login using their facebook credentials
* First time logging in user will need to enter their facebook email and password after selecting facebook login button
* This page will not display if user's credentials are still valid and user has not logged out

#### Watchlist Page ####
* This is the main page that a user is taken to after logging into the application
* Displays a list of qutoes for a single watchlist that the user has saved (device + user specific)
* On this page they can remove quotes from their watchlist by pressing the (i) indicator on the right of the cell
* Quotes on this page will refresh every 5 seconds (10 seconds after first logging in)
* Watchlists can be managed by pressing the wachlist dropdown to open the "Watchlist Editing Page"
* Quotes can be added to the watchlist by first pressing search to open the "Symbol Search Page"
* A user can log out by pressing the logout button at the top left of the page, this will direct the user back to login

#### Watchlist Editing Page ####
* Opened by pressing on the Watchlist Dropdown
* Watchlist names can be changed by pressing the edit button, entering new text in the name field, and pressing "Done" on keyboard (duplicate names not allowed)
* Watchlists can be deleted by pressing edit -> delete -> Continue when alert is displayed

#### Symbol Search Page ####
* Opened by pressing on the search button in the top of the "Watchlist Page"
* Entering text in the field (stock name or symbol) will show a filtered list of possible selections
* By selecting on a list item the symbol will be added to the watchlist that is currently displaying on the "Watchlist Page"
* To add symbols to a different watchlist, user must select the desired watchlist in the Watchlist Dropdown first


### Who do I talk to? ###

* Brett Johnsen - Owner