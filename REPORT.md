# Pala
iOS app to meet people that will be attending the same events as you

# Description
Nowadays, apps like Tinder and Happn are immensely popular. With these apps user's can like/dislike eachother, and when there is a match they can chat so they can meet up. However, the threshold for meeting up with a complete stranger is still pretty high. The perfect place to meet people still isn't on your couch swiping people left and right, but on parties/festivals/other events!

Pala combines these two concepts. With the Pala app you can like (and hopefully get a match) the people who will be visiting the same event/party/festival/etc as you. When you get a match with someone, the threshold of meeting up is much lower because soon you will be on the same party together. Just go grab a beer together! If it doesn't work out, you just go back to your friends you were visiting the party with.

Pala is linked to your Facebook account. After logging in you select the (facebook) event you are attending and you want to meet new people at. Then you see all people that use the app and are attending that event too. When you "Like" someone who also "Likes" you, you can chat to meet up IRL ASAP!

# Technical overview

### View controllers and flow

The app's view is controlled by five viewcontrollers. These viewcontrollers control everything that has to do with the view, user interaction and data presentation.   
  The first controller that will be loaded is the LoginViewController. Here is checked if the user is already logged in. If not, a very basic starting screen is shown with a Facebook login button, after which he will log in with his native Facebook app or through the Facebook website.  
  When the user is logged in, he will arrive in the main section of the app, consisting of three views held together by a so-called "Hamburger" menu. The main view of the app is the center of this hamburger menu: the "Wall". Here the user sees the other users that will be attending the event he selected and can he/she like and dislike users, the main activity of the app.  
  The leftmost view is controlled by the EventsViewController. Here the user sees his profile, selects gender preference, logs out and most importantly selects an event.  
  The rightmost view is where the magic happens: the ChatsTableViewController. Here the user sees all his matches in a tableview. When he selects a user he is redirected to a view controlled by a PrivateChatController. Here the two lovebirds-to-be can privately chat with eachother to meet up!

### Parse

Parse is used for the app's database. Every user has a unique Parse user (PFUser) object that is linked to his Facebook. Along with the user's basic profile information, the Parse user object has the following properties:
- likedUsers: an array of objectIDs of all users the user has liked.  
- dislikedUsers: same as above, but array of disliked users
- matches: an array of objectIDs of users the user has a match with
- events: an array of eventIDs of the events the user is attending

### PubNub

PubNub is used for the chat functionality. PubNub makes sending messages between users easy. Simply put: each user has his own channel and can push messages to another user's channel. The channel is linked to the user through their objectID in Parse. 

### Parse Cloud code

Parse Cloud Code is used to match users and send push notifications. With Cloud Code you can run Javascript code in the Parse clode rather than on the iOS device itself.  
Cloud Code is needed for the matching of users because the current user does not have the authorization to edit another user from his/her device. In Cloud Code the "masterkey" is used to make this possible. This is needed to make sure both users have the other user in their "matches" array.  
In Cloud Code it is easy to send push notifications to a specific user, for example when there is a new match or a message received. This is done by specifying a query, after which the push notification is sent to all users (or in this case, one) that the query returns.

## Classes and their most important methods

The data handling is done in three classes: the User, Chat and Wall class.

The User class represents the app user and here are all methods defined that have to do with the User. The two most important methods are **getUserEvents** and **populateNewUserWithFacebookData**. The former queries facebook for the events the user is attending. The latter is called when a user signs in for the first time and makes sure that the user's Parse object (PFUser) is filled with his profile info.

The Wall class handles everything that has to do with the data presentation and interaction on the Wall. The three important methods that are defined here are **getUsersToShow**, **likeUser** and **dislikeUser**.  
**getUsersToShow** queries Parse for the correct users to show on the wall. That is, show all users that are the preferred gender, that attend the selected event, that are not in the user's "liked-/dislikedUsers" or "matches" array.  
The other two methods handle the (dis)liking of another user. When User A likes User B, there is checked if User B has User A in his likedUsers. If so, both A and B get a notification that they have a new match, the other's objectID is removed from likedUsers and added to matches. If not, User B's objectID is simply added to User A's likedUsers. Disliking a user is simply adding the other user to your 'dislikedUsers' array, so that they will not show up on the Wall anymore.

The Chat class handles all the chat data handling. The most important methods to discuss here are **saveMessageToUserDefaults** and **loadUnseenMessagesFromServer**. The chat history is kept in NSUserdefaults. When a message is sent or received while the app is active, the message is directly saved to the userdefaults with **saveMessageToUserDefaults**. However, when the app is inactive this is not possible. Here the **loadUnseenMessagesFromServer** method comes in. This method queries PubNub for all messages since the time of the last saved message (saved in userdefaults as "lastSaveDate") and stores them in NSUserdefaults.

# Design decisions

**Wall**  
I wanted to be able to show multiple users at once instead of presenting the users one by one. I want users to like someone that stands out to them, in stead of having to 'rate' every user. With this in mind I made the pictures as big as possible, to enable the user to make a decision on the Wall view only.

**Current event -> all events**  
Originally I wanted to make it so that users could use the app only **on the day of the event**. However, as this would mean that either people would need to be smartphoning at the event or the timeframe to use the app for that event would become pretty small, I've chosen to enable the user to use the app with **all** their future events. 







