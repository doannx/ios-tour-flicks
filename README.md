# Project 1 - *Flicks*

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **15** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API.
- [x] User sees an error message when there is a network error.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [x] Implement segmented control to switch between list view and grid view.
- [x] Add a search bar.
- [x] All images fade in.
- [x] For the large poster, load the low-res image first, switch to high-res when complete.
- [x] Customize the highlight and selection effect of the cell.
- [x] Customize the navigation bar.

The following **additional** features are implemented:

- [x] Friendly UI
- [x] Save data (search criteria) as well as user settings (style of displaying data: table or grid)

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](Flicks.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

1. Only displaying well in the poitrait mode on iphoneSE screen :sweat:
2. Spending a lot of time on doing GUI but still can't make it work as expected, especially the collectionView layout :angry:
3. Can not fill the background image full of navigation bar :sweat:
4. Still have bug in pull-to-request (work with collection view but not with table view) & infinite loading (work with table view but not with collection view), I reviewed my code hardly but still not find the cause yet :sweat:
5. Can not hide the task bar in detail screen
6. Still not find out how to register/catch the valueChanged event for the tabBar (because I use the tabBar by programmatic, not the UITabBar control, following the tutorial video that is suggested at Walkthrough Videos)
7. Xcode is so ugly

## License

    Copyright [2017] [toicodedoec]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
