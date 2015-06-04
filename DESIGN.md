# Pala: Design document

## SDKs
* Parse SDK
* Facebook SDK
* (SDK for the chat functionality)


## Classes
* User (from Parse SDK)
	* Properties
		- ProfilePictures
		- Age
		- Gender
		- About
		- Events
		- CurrentEvent
		- LikedUsers		
		- DislikedUsers
		- Matches
	* Methods
		- PopulateUser: populates the Parse user with the user's Facebook data
		- CheckLike: when the users likes another user, check if the user is in the other's 'LikedUsers'
		- LikeUser: adds the liked user to 'LikedUsers'
		- DislikeUser: adds the 'disliked' 'DislikedUsers'
		- DeleteAccount: deletes the user's account from Parse
		- NewMatch: if there is a new match, create new chat class and add to Matches
		- DeleteMatch
* Chat
	* Properties
		- OtherUser: the user on the other end
	* Methods
		- InitChatWithOtherUser
		- SendMessage
		- ShareLocation
		- EndChat: deletes chat and match
		
* Wall
	* Properties
		- UsersAtEvent
		- UsersToDisplay
	* Methods
		- GetUsersAtEvent: gets all users from the Parse database that have CurrentEvent property same as the given event
		- GetUsersToDisplay: all users that need to be displayed on the wall (UsersAtEvent excl. LikedUsers and DislikedUsers)
		
		

## View Controllers
* LoginViewController
	View where the user logs in using facebook

* EventsViewController
	View where the user selects the event he is visiting out of his attending FB event

* WallViewController
	View where the user sees all Pala users on the same event as the user. He can select a user to see more information.

* ChatsViewController
	View where the user sees all his matches (=chat), and can select a match to chat/share location with the user on the other end

* SettingsViewController
	View where the user can adjust settings such as his profile, age range and gender of the users on the wall

## Mockups
1

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/LoginScreen.jpg" width="250">
2

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/EventSelect.jpg" width="250">
3

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/WallScreen.jpg" width="250">
4

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/ChatScreen.jpg" width="250">
5

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/InChatScreen.jpg" width="250">