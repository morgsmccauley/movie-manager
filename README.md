# Movie Manager

Simple swift 3 app for:
1. Browse Top/Coming Soon/Popular movies in a collection view with inifinity scroll
2. SAYT for movies with results displayed in a table view
3. Star/Save movies to persistent memory to view later using the Core Data Api
4. View more details about movies, accessible through all the above screens

All movie data pulled from [The Movie DB](https://www.themoviedb.org/documentation/api).

## To Run:

1. Clone project
2. Open `movie-manager-app.xcodeproj` in Xcode
3. Build & Run

## TO DO:

- [ ] Youtube integration - play trailer
- [X] Move detail data fetch/transer functions in to separate class (code repeated in all three controllers)
- [ ] Hide detail sections if no data present
- [ ] App icon and launch screen
- [ ] Add more appropriate default values / images

## Known Issues: 
- Cant set runtime on movie object when detail view is opened
- Cant open discovery menu when scrolling
- Discovery menu partially hiden on first load due to initial scroll when hiding the status bar
