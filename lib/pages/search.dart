import 'package:amer_share/models/user.dart';
import 'package:amer_share/pages/home.dart';
import 'package:amer_share/pages/profile.dart';
import 'package:amer_share/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// CollectionReference usRef = Firestore.instance.collection('users');

class Search extends StatefulWidget  {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  List<User> allUsersModels = [];
  Future<QuerySnapshot>
      searchResultsFuture; // this is needed for setting the State and use the variable in the widget
  TextEditingController searchController =
      TextEditingController(); // this will be used for clearing

  //########## building Handle search Method ##########
  handleSearch(String query) {
    Future<QuerySnapshot> searchUsers = usersRef
        .where('displayName', isLessThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = searchUsers;
      // by writing this line we can check if the searchResultsFuture is equals to
      // null or not .... to be able to return different Widgets in body of the scaffold
    });
  }
bool get wantKeepAlive=> true;

  @override
  Widget build(BuildContext context) {
  super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.75),
      appBar: buildSearchAppBar(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }

  Widget buildSearchAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: TextFormField(
        onFieldSubmitted: handleSearch,
        controller: searchController,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                searchController.clear();
              },
              icon: Icon(
                Icons.clear,
                size: 30,
              ),
            ),
            prefixIcon: Icon(
              Icons.account_box,
              size: 35,
            ),
            filled: true,
            hintText: 'Search for a user.....'),
      ),
    );
  }

  Widget buildNoContent() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset(
              'assets/images/search.svg',
              height: (orientation == Orientation.portrait) ? 300 : 200,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  fontSize: 60,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Widget buildQuickResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        // so If we used to searchUsers here we will Bring error So we will use A variable in the SetState Function
        builder: (context, AsyncSnapshot<QuerySnapshot> amer) {
          if (!amer.hasData) {
            return circularProgress(context);
          } else {
            List<Text> allResults = [];
            amer.data.documents.forEach((element) {
              User user = User.fromDocument(element);
              allResults.add(Text(user.username));
            });
            return ListView(
              children: allResults,
            );
          }
          return Container();
        });
  }

  Widget buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> amerSearchSnapshot) {
          switch (amerSearchSnapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: Text('None Found'),
              );
              break;
            case ConnectionState.waiting:
              return circularProgress(context);
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (!amerSearchSnapshot.hasData) {
                return circularProgress(context);
              }
              // the First solution is to take the the out from the snapshot and
              // create List<Text> and users<User> in one tick
              List<UserResult> searchResults = [];
              amerSearchSnapshot.data.documents.forEach((DocumentSnapshot doc) {
                // we need to Get all the users in the system uaAmer
                User singleUser = User.fromDocument(doc);
                allUsersModels.add(singleUser);
                //
                User user = User.fromDocument(doc);
                UserResult userResult = UserResult(user); // we are preparing instance of the Stateless Widget userResult
                searchResults.add(userResult);

                /// everyTime the userResult Will be added to the list
                /// and at the end of the forEach we will have list of all the users stl
                // This List(searchResults) will be used in the Widgets tree

                // for checking Step
                // print(doc.data['username']);
              });

              /* #########   THIS IS THE MAIN WIDGET TO BE REBUILD UA_AMER ######*/
              return ListView(
                  // we can path any one of the searchResults or names
                  children: searchResults);
          }
          return Container();
        });
  }
}

//************* This is for optimizing the search ****************
class UserResult extends StatelessWidget {
  User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleShowingCompleteProfile(context,userId:user.userId ),
      child: Container(
        margin: EdgeInsets.all(4),
        color: Theme.of(context).primaryColor.withOpacity(0.3),
        child: ListTile(
          subtitle: Text(user.username),
          title: Text(
            user.displayName,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(user.userPhoto),
          ),
        ),
      ),
    );
  }

  handleShowingCompleteProfile(BuildContext context,
      {String username, String userId}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Profile(
        profileId: userId,
      );
    }));
  }
}
