Champions
=======

A web app displaying League of Legends champion stats and abilities.

Currently hosted at [https://sleepy-cliffs-16895.herokuapp.com/](https://sleepy-cliffs-16895.herokuapp.com/)

Features
-------
* Dynamic retrieval of champions and their stats from Riot Game's latest API.
* Homepage of champions filterable by role.
* A 'Compare' page allowing users to view champions between different game versions.
* An index page of champions filterable by role and a table of sortable stats&mdash;from general stats to level 1 and level 18 stats.
* Data on number of missing/misplaced API data for all champions' abilities.
* Responsive and aesthetic layouts for desktop and mobile views.

Desktop & Mobile/Tablet Previews
-------
### Homepage
<img src="http://i.imgur.com/TdV8ch7.png" width="600">&nbsp;<img src="http://i.imgur.com/IcgKDC3.png" width="207">
### Champion Stats
<img src="http://i.imgur.com/CLP1Sgg.png" width="600">&nbsp;<img src="http://i.imgur.com/IehIA7G.png" width="207">
### Champion Abilities
<img src="http://i.imgur.com/gIRZvX1.png" width="600">&nbsp;<img src="http://i.imgur.com/CNhLb5G.png" width="207">
### Champion Index with Sortable Stats
<img src="http://i.imgur.com/i76oDoL.png" width="600">&nbsp;<img src="http://i.imgur.com/FWX6zJx.png" width="207">
### Champion Comparisons Page - Stats
<img src="http://i.imgur.com/sVfVjOP.png" width="600">
### Champion Comparisons Page - Abilities
<img src="http://i.imgur.com/eRCofu3.png" width="600">

Possible Future Updates
-------
### Application
* Analytics of stats' and abilities' values.
* Enable a way to filter champions by their secondary roles.
* Create an item/runes/masteries database.
* Create a feature to theory-craft by allowing users to add items/runes/masteries and see corresponding changes to champion stats abilities.

### Code
* Check game version only during index/missing data pages.
* Add a more robust set of tests and champion attribute validations.
* The homepage currently renders every champion twice&mdash;once for the 'All' tab and once for the tab corresponding to their primary role. Use jQuery to render and filter the champions dynamically.

Shoutouts
-------
* [Bootstrap](http://getbootstrap.com/) - for a great HTML, CSS, and JS framework.
* [Cloud9](https://c9.io/) - for providing an accessible all-in-one environment for web development. 
* [Heroku](https://www.heroku.com/) - for providing a place to host web apps.
* [Ruby on Rails Tutorial](https://www.railstutorial.org/) - for the comprehensive and thorough tutorial on Ruby on Rails.
* [tablesorter](http://tablesorter.com/docs/) - for a way to enable sorting on tables.
* [w3schools](http://www.w3schools.com/) - for endless resources on web development topics.
