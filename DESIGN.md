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

## Mockups and how it works
1. Here the user logs in using his Facebook account. When the user logs in for the first time, he is asked for permission to use his public profile and events. After the login is completed, a new Parse user is created.

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/LoginScreen.jpg" width="250">

2. This view is populated with the user's attending FB events (on the current day). After the user selects the event, all users at that event are retrieved from the Parse database. 

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/EventSelect.jpg" width="250">

3. The wall is populated with all users at the selected event, except the users already 'Liked' or 'Disliked'. Here a user can click on the displayed users to see their profile, and like and dislike users.

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/WallScreen.jpg" width="250">

4. A menu will slide in from the right of the screen, displaying all the matches (and thus chats) the user has. Here the user can select a match to go to the chat with that person.

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/ChatScreen.jpg" width="250">

5. The chat menu. Here the two matched users can chat and share location so they can soon meet up!

<img src="https://github.com/bjvanlinschoten/EventDateApp/blob/master/docs/InChatScreen.jpg" width="250">