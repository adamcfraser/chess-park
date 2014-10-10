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


