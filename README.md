Champions
=======

Features
-------
* Dynamic retrieval of champions and their stats from Riot's API, automatically updating as the API updates.
* Homepage of filterable champions.
* An index page with champion filtering and a table of sortable stats&mdash;from general stats to level 1 and level 18 stats.
* Responsive and visually pleasing layouts for desktop and mobile views.
* Dynamic retrieval of missing/misplace API champion ability data (takes a few seconds to process all champion abilities and load the page. A possible future update will make the page static and only update when the API updates).

Desktop & Mobile/Tablet Previews
-------
### Homepage
<img src="http://i.imgur.com/Q3O4SzT.png" width="600">&nbsp;<img src="http://i.imgur.com/Q4ZzyuS.png" width="215">
### Champion Stats
<img src="http://i.imgur.com/aflJHv9.png" width="600">&nbsp;<img src="http://i.imgur.com/Bpakv0e.png" width="215">
### Champion Abilities
<img src="http://i.imgur.com/gIRZvX1.png" width="600">&nbsp;<img src="http://i.imgur.com/UQtBVZ8.png" width="215">
### Champion Index with Sortable Stats
<img src="http://i.imgur.com/i76oDoL.png" width="600">&nbsp;<img src="http://i.imgur.com/TpZ4v5i.png" width="215">

Possible Future Updates
-------
* Use the dynamic aspects of the web application to retrieve and store all data in a database, thereby creating a low-load static website that only updates data when the API version changes, e.g. from v6.2.1 to v6.3.1. 
* Enable a way to filter champions by their secondary roles.
* The homepage currently renders every champion twice&mdash;once for the 'All' tab and once for the tab corresponding to their primary role. Use jQuery to render and filter the champions dynamically.
* Create an item/runes/masteries database.
* Create a feature to theory-craft by allowing users to add items/runes/masteries and see corresponding changes to champion stats abilities.
* Add a more robust set of tests and champion attribute validations.
* Make all the homepage filter tabs the same size.

Shoutouts
-------
* [Bootstrap](http://getbootstrap.com/) - for a great HTML, CSS, and JS framework.
* [Cloud9](https://c9.io/) - for providing an accessible all-in-one environment for web development. 
* [Heroku](https://www.heroku.com/) - for providing a place to host web apps.
* [Ruby on Rails Tutorial](https://www.railstutorial.org/) - for the comprehensive and thorough tutorial on Ruby on Rails.
* [tablesorter](http://tablesorter.com/docs/) - for a way to enable sorting on tables.
* [w3schools](http://www.w3schools.com/) - for endless resources on web development topics.
