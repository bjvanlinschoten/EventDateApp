
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.define("match", function(request, response) {
	
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
