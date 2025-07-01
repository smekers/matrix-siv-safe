# Matrix chat app
This app is a sample on how you can use [matrix](https://matrix.org) in your app for open source chat.

It's a simplified version so it's beginner friendly.

## How to run this app
Simply clone/download this app and open `MatrixSiv.xcodeproj`. Then, run the application and you're done. 

```
💡 If you're getting errors when running, try resetting package caches or resolving package versions then clean the build folder before running
```

## How to use matrix on your own app
1. Create your app
2. Install [MatrixRustSDK](https://github.com/matrix-org/matrix-rust-components-swift/) package in SPM
    1. Open your project file in XCode
    2. In `Package Dependencies` add `https://github.com/matrix-org/matrix-rust-components-swift/`. This app uses up to next major version from verison 25.4.16 but you may use other versions. However, the sample app might be 100% compatible with your version.
3. (Optional) Setup your own homeserver. [Guide video](https://www.youtube.com/watch?v=Yvrts8us4OU&t=542s)
4. Use this app as a basis for using Matrix on your app.


``` 
💡 You have to set up your own matrix appservice to have your own homeserver and to register users.
```

## Where can samples be found?
### User Login
[SignInView](v2/Auth/SignInView.swift)
### User Registration
[CreateAccountView](v2/Auth/CreateAccountView.swift)
### User Logout
[MenuView](v2/MenuView.swift)
### Room List
[RoomListView](v2/RoomListView.swift)
### Room Chat
[ChatView](v2/ChatView.swift)

## Basic MatrixRustSDK Classes and Protocols
- Client - handles the current session, logging in and out etc
- Room - a chat room. it can have multiple users
- RoomListItem - a class similar to room but has additional information for the user to be able to show it in a room list
- Timeline - messages in a room ordered by the time sent
- Event - an event in a timeline. It has different types but most commonly used is `message`.

## MatrixManager and RoomManager
We created this app because we had a hard time trying to figure out how to make MatrixRustSDK  work and when we tried asking other people they just told us to look at how Element iOS implemented it. As usual with big apps, they're using a framework that's well suited to big apps but is a pain in the ass to look through especially if you're a new dev and have no experience hunting down code. 

So for this app, we put most of the work in just 2 files/classes. [MatrixManager](v2/Matrix/MatrixManager.swift) and [RoomManager](v2/Matrix/RoomManager.swift)

### MatrixManager
MatrixManager is a singleton class that manages the user and the roomList of the app. Listed here are the notable functions

#### Static functions
##### `login`
Called only during sign in. Logs in the user using the homeserver, username, and password provided by the user
##### `restoreSession`
Restores session when there's a stored session in UserDefaults
##### `registerUser`
Registers user with the data provided in `CreateAccountView`

#### Regular functions
##### `newLogin`
Sets the client and calls `loadClient`
##### `loadClient`
Sets delegates and listeners so we can monitor the client and the room list
##### `isLoggedIn`
Checks if client has a session
##### `logout`
Logs out client and resets all the stored variables from the current user
##### `getData`
Returns a UIImage from the data returned by `client.getMediaContent`. The `avatarURL`s can't be fetched without this
##### `getRoomManager`
Returns a RoomManager based on the given roomId. Checks the `roomManagersDict` first if the `[roomId : RoomManager]` keyValue pair can be found. If found, returns the existing RoomManager. If not found, creates a new RoomManager, stores it it the roomManagersDict, and then returns the new RoomManager. This ensures that the timeline for a room is initialized only once and it has only one TimelineListener.
##### `getOrCreateDMRoom`
Gets the DM (direct message) room between two users 
##### `createDM`
calls `getOrCreateDMRoom` and sends the initial message provided by the user
##### `createRoom`
creates room and sends initial message provided be the user
##### `refreshRooms`
Refreshes room list data
##### `onUpdate`
Updates the stored room list. This function is automatically called by the RoomListListener




### RoomManager
RoomManager handles everything for a room
#### Notable functions
##### `setup`
Initializes the Room's timeline and adds a listener
##### `initializeTimeline`
Initializes timeline. You can change the types of events to add in the timeline by changing `eventTypeFilter`
##### `paginateBackwards`
Loads older messages. You can change the number of messages to load by changing `numEvents`
##### toggleReaction
Toggles the reaction of the user for the given eventId
##### sendPlainMessage
Sends a text message to the room. Note that are not limited to text. Use this function as a template on sending messages but messages can be markdown, json, html, image, or other file types.
##### onUpdate
This function gets called automatically when there's a new event in the room. Use this to update the view of your messages

### How to login the user?
The login screen is found in [SignInView](v2/Auth/SignInView.swift). It asks for the user's username and password and calls the static `login` function from [MatrixManager](v2/Matrix/MatrixManager.swift).

The login function creates a client from `MatrixRustSDK` `ClientBuilder`. Then it tries to login that client to the matrix server. The client is stored in `MatrixManager.shared`

### How to know if there's a user logged in
[MatrixManager](v2/Matrix/MatrixManager.swift) has a function called `isLoggedIn` which tries to get the client's session. No session means the client is logged out

### How to register the user?
[MatrixManager](v2/Matrix/MatrixManager.swift) has a static function called `registerUser` which is used in [CreateAccountView](v2/Auth/CreateAccountView.swift).
MatrixRustSDK does not provide a way to create/register a user so we're utilizing Swift's `URLSession` library to create a user using their REST API [/register](https://spec.matrix.org/v1.15/client-server-api/#post_matrixclientv3register) endpoint. Please note that for the `registerUser` function to work, you should set the AppConstants based on the data from your own homeserver. If it's still not working (probably because the endpoint is updated), you can experiment with it using Postman or other API testing apps

### How to get the user rooms?
You can get the user rooms by simply calling `client.allRooms()` from [MatrixManager](v2/Matrix/MatrixManager.swift). However, this method might return 0 rooms if you called it too early.

Another way to get rooms is by using `RoomListEntriesListener`. You can find it in [MatrixManager](v2/Matrix/MatrixManager.swift)'s `loadClient` function.
By conforming MatrixManager to the RoomListEntriesListener protocol, we allow it to listen on updates to the roomList. From there, you can decide what you want to do with the RoomListItems

Please note that the rooms returned by allRooms() or RoomListEntriesListener are not ordered in particular so I suggest making a function to sort the rooms based on what you need.

### How to get the room messages?
For basic `MatrixRustSDK`, you need to get a Room then initialize it's timeline and have a class that conforms to `TimelineListener` so you can get timeline updates such as new messages or new reactions. For this app, we use [RoomManager](v2/Matrix/RoomManager.swift).

`RoomManager` initializes the timeline and controlls the pagination so we can see messages and reactions in real time. RoomManager also provides the functions to interact with a room like sending messages and reactions.

