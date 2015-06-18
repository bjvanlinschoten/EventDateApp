
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.define('match', function(request, response) {
	
	var otherUserId = request.params.otherUserId,
		currentUserId = request.params.currentUserId;
	
	var User = Parse.Object.extend('_User'),
		user = new User({objectId: otherUserId});
		
	user.add('matches', currentUserId);
	user.remove('likedUsers', currentUserId);
		
	Parse.Cloud.useMasterKey();
	user.save().then(function(user) {
		response.success(user);
	}, function(error) {
		response.error(error)
	});
});

// Parse.Cloud.define('getUsersToShow', function(request, response) {
// 	
// 	var event = request.params.event;
// 	var currentUser = Parse.User.current();
// 	
// 	if currentUser.get('gender') == 'male' {
// 		var gender = 'female'
// 	} else {
// 		var gender = currentUser.get('gender');
// 	}
// 	
// 	
// 	var genderQuery = new Parse.Query(Parse.User);
// 	genderQuery.equalTo('gender', gender);
// 	
// 	var eventQuery = new Parse.Query(Parse.User);
// 	eventQuery.equalTo('event', event)
// 	
// 	var mainQuery = Parse.Query.or(genderQuery, eventQuery)
// 	
// 	mainQuery.find({
// 		success: function(usersAtEvent) {
// 			
// 		} 
// 	});
// }