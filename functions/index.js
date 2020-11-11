const functions = require('firebase-functions');
const admin = require('firebase-admin')  ;
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower =functions
.firestore
.document("followers/{userId}/userFollowers/{followerId}")
.onCreate(  async (snap, context) => {
console.log("Follower Created", snapshot.id);
const userId=context.params.userId;
const followerId=context.params.followerId;

// create the posts of the followerPosts
const followedUserRef=
 admin
.firestore()
.collection('posts')
.doc(userId)
.collection('userPosts');

// 2] create the following user's timeline ref
const timelinePostsRef =admin
.firestore()
.collection('timeline')
.doc(followerId)
.collection('timelinePosts');

//3[ get followers users post

const querySnapshot=await followedUserRef.get();
querySnapshot.forEach(doc => {
  if(doc.exists){
  const postId=doc.id;
  const postData=doc.data();
  timelinePostsRef.doc(postId).set(postData);
          }
  })
});


exports.onDeleteFollower= functions
.firestore
.document("followers/{userId}/userFollowers/{followerId}")
.onDelete(  async (snapshot,context) => {
console.log("Follower Deleted",snapshot.id);
const followerId=context.params.followerId;

const timelinePostsRef =admin
.firestore()
.collection('timeline')
.doc(followerId)
.collection('timelinePosts')
. where("ownerId","==",userId)  ;

const querySnapshot=await timelinePostsRef.get();
querySnapshot.forEach(doc  =>{
   if(doc.exists){
   doc.ref.delete();
   }
   });
});

//onCreatePost when the post is created we wanted to add this post at the timeLine
exports.onCreatePost=functions
.firestore
.document("/posts/{userId}/userPosts/{postId}")
.onCreate( async(snapshot,context) => {
const postCreated =snapshot.data();
const userId=context.params.userId;
const postId=context.params.postId;

// to get all the followers of the user who made the post
const userFollowersRef=admin.firestore().collection('followers')
.doc(userId)
.collection('userFollowers');

const querySnapshot=await userFollowersRef.get();
//2) Add new post to each follower's timeline
querySnapshot.forEach( doc => {
   const followerId=doc.id;

   admin.firestore()
   .collection('timeline')
   .doc(followerId)
   .collection(timelinePosts)
   .doc(postId)
   .set(postCreated)
   } ) ;
} ) ;