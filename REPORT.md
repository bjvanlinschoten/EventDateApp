# Pala
iOS app to meet people that will be attending the same events as you

# Description
Nowadays, apps like Tinder and Happn are immensely popular. With these apps user's can like/dislike eachother, and when there is a match they can chat so they can meet up. However, the threshold for meeting up with a complete stranger is still pretty high. The perfect place to meet people still isn't on your couch swiping people left and right, but on parties/festivals/other events!

Pala combines these two concepts. With the Pala app you can like (and hopefully get a match) the people who will be visiting the same event/party/festival/etc as you. When you get a match with someone, the threshold of meeting up is much lower because soon you will be on the same party together. Just go grab a beer together! If it doesn't work out, you just go back to your friends you were visiting the party with.

Pala is linked to your Facebook account. After logging in you select the (facebook) event you are attending and you want to meet new people at. Then you see all people that use the app and are attending that event too. When you "Like" someone who also "Likes" you, you can chat to meet up IRL ASAP!

# Technical overview


## View controllers and flow

The app's view is controlled by five viewcontrollers. These viewcontrollers control everything that has to do with the view, user interaction and data presentation.   
  The first controller that will be loaded is the LoginViewController. Here is checked if the user is already logged in. If not, a very basic starting screen is shown with a Facebook login button, after which he will log in with his native Facebook app or through the Facebook website.  
  When the user is logged in, he will arrive in the main section of the app, consisting of three views held together by a so-called "Hamburger" menu. The main view of the app is the center of this hamburger menu: the "Wall". Here the user sees the other users that will be attending the event he selected and can he/she like and dislike users, the main activity of the app.  
  The leftmost view is controlled by the EventsViewController. Here the user sees his profile, selects gender preference, logs out and most importantly selects an event.  
  The rightmost view is where the magic happens: the ChatsTableViewController. Here the user sees all his matches in a tableview. When he selects a user he is redirected to a view controlled by a PrivateChatController. Here the two lovebirds-to-be can privately chat with eachother to meet up!

## Classes

The data handling is done in three classes: the User, Chat and Wall class.

The User class represents the app user and here are all methods defined that have to do with the User. 



