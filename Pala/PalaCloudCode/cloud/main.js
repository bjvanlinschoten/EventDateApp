
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
	
	// Push notification to user
	var query = new Parse.Query(Parse.User);
	query.equalTo('objectId', otherUserId);
	
	var pushQuery = new Parse.Query(Parse.Installation);
	pushQuery.matchesQuery('user', query);
	
	Parse.Push.send({
		where: pushQuery,
		data: {
			aps: {
				alert: "New match!"
				sound: "default"
			}
		}
	}, {
		success: function (){
			response.success("Hello world!");
		},
		error: function (error) {
			response.error(error);
		}
	});
});

