-----------------------------------------------------------------------------------------------------------------------
Movie App
-----------------------------------------------------------------------------------------------------------------------
- Created a TMDB account for Movie List App (https://www.themoviedb.org) and 
	get your own API key (https://developers.themoviedb.org/3/getting-started)
- You can load movie data information with your API key with the following urls:
	Get Now Playing : http://api.themoviedb.org/3/movie/now_playing?api_key=<<api_key>>
	Get Popular : http://api.themoviedb.org/3/movie/popular?api_key=<<api_key>>
	Get Top Rated : http://api.themoviedb.org/3/movie/top_rated?api_key=<<api_key>>
	Get Upcoming : http://api.themoviedb.org/3/movie/upcoming?api_key=<<api_key>>
- Each movie entry has a field called “poster_path” or , which is where you should download the picture for the movies.
	URI: http://image.tmdb.org/t/p/<<size>>/<<poster_path>>"; // size : "w92", "w154", "w185", "w342", "w500", "w780", or "original".
- Auto Layout constraint (No Storyboard, all in code)
- Works in both X and smaller screen
- Master/Detail flow
- Master view is a tableview
- Custom Cell implementation
- Fetches movie list from TMDB server through Json downloading
- Displays small image of poster, title
- Downloads image from the poster link
- Selects a movie by tapping a row, then loads the detail view of the design.
- Deletes a movie with swiping action
- Detail view
- Customized detail view design
- Includes: 
	- Title, rating, description, ...
	- Rating is visual (not text)
	- Downloads movie detail from TMDB with id of Movie
	- Download images from the server (NO local image)
	- Uses 2 poster/backdrop images to manipulate >= 4 collection view items
- MVC design pattern
- Defined model for fetching Movie Json data
- Movie list/movie detail
	- Is Decodable (No need to parse JSON data)
- Uses Firebase for login authentication/reviews for movies
- Movie information is downloaded from API
- User credentials/profiles are created/saved in Firebase
- Users' reviews are saved in Firebase and fetched into master/detail screens
- Login Screen for login or regster / Profile Editing Screen
	- if successfully logged in, displays the list of movies fetched from API
	- if successfully registered, displays the profile screen to add profile image and other information
	- profile image can be selected and uploaded into firebase
	- if not selected, uses a default image for profile image
- Master/Detail flow:
	- Master View (TableView)
	- poster icon, title, # of reviews for each movie if they exist
	- Detail View (either TableView or CollectionView)
	- There are multiple sections; for example, first section is for movie information from API and second section is for reviews from Firebase
	- Reviews can be written by multiple logged users
	- user name, review written by the user, # of like or dislike tapped by other users
	- review cell design:
		- user name
		- review text
		- like/dislike buttons and number for each
		- review can be edited/deleted only by author
	- Navigation bar must show user information (profile icon and name)
	- when tapped, Profile Screen should be launched to edit
- Firebase Auth, Database, and Storage
	- Authentication
	- Database -- realtime update
	- Review data model
	- Storage to save profile images
-----------------------------------------------------------------------------------------------------------------------