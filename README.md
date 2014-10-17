chess-park
==========

Couchbase Mobile sample app to test basic Couchbase Lite and Sync Gateway functionality

Overview 
========
Loosely based on the idea of playing chess in a park - users have multiple games on the go at once, can switch between games
taking their turns.

Details
=======
- Users authenticate via basic auth against Sync Gateway
- 'Waiting for Games' shows a list of games waiting for players.  Users can create their own game here, or join
an existing.  All games are initially public.
- When a game is full (two players), it becomes private and moves to the 'My Games' list
- Clicking on a game in the My Games list takes you to the game.  If it's your turn, you can make a move. 
- Lists and match itself are hooked up to liveQuery, so they auto-refresh when other player takes an action

Building and Running
====================

1. Clone or download the repository
2. Open ChessPark.xcodeproj
3. In AppDelegate.m, modify kSyncHost to point to your Sync Gateway
4. Set up your Sync Gateway
    1. Update the sync gateway config file [chessParkConfig.json](https://github.com/adamcfraser/chess-park/blob/master/chessParkConfig.json) to point to your Couchbase Server bucket.
    2. Start Sync Gateway
    3. Add a few users via the admin API.  Here's a sample call using httpie: 
`
  http PUT localhost:4985/chess-park/_user/adam name=adam password=1234
`
5. Run 
