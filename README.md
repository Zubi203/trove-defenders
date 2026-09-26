<img width="1907" height="1068" alt="Screenshot 2026-09-04 113710" src="https://github.com/user-attachments/assets/a0e9afa2-134f-4e86-ac31-daeef9361696" />

# **TROVE DEFENDERS**

### The Game
Trove Defenders is a turn-based tactics game inspired by the indie title "Into the Breach". 
It features grid-based strategic gameplay, challenging Utility AI, and 8 different party members to choose from, each with their own unique and powerful abilities.
The game consists of 6 total levels, each introducing new enemy types and stage hazards. This is a portfolio project meant to showcase my proficiency in gameplay systems programming and the Godot Engine

### Project Features
- Complex Utility AI that chooses the most effective enemy actions based on a scoring system
- State-driven turn based combat system
- Use of the Command pattern to allow player and enemy actions to be queued and executed in a clean order
- Highly scalable composition based design makes it incredibly simple to set up new characters and projectiles
- Resource driven design allows all the character and projectile data to be stored as lightweight and reusable resources which can be accessed by or assigned to any part of the project that requires it
- Showcases excellent use and understanding of the Godot tilemap system
- Expressive and responsive UI animations through the use of Tweens
- The Observer Pattern and a global Event Bus Singleton have been used to allow different parts of the game to communicate easily while minimizing coupling
- A music manager Singleton that enables smooth transitions between music tracks while also letting music persist between scene changes

### Engine
- This project was made using the Godot Engine
- All the code for this project is written in GDScript

### How to Run Project
- If you're interested in playing the full game, it can be played in browser on itch.io: https://zubi-dev.itch.io/trove-defenders
- If you're interested in running the project on the Godot Engine, simply download the project files from this repository and import them into Godot
- The code base for this project is fully commented and uses easy-to-understand variable, method, and class names

### Credits
- All the code for this project was done by me
- Character Assets: https://kenney-assets.itch.io/tiny-dungeon
- Tilemap Assets: https://scrabling.itch.io/pixel-isometric-tiles
- Background for title screen and menus: https://anokolisa.itch.io/sidescroller-pixelart-sprites-asset-pack-forest-16x16
- Sound effects and music: https://leohpaz.itch.io/minifantasy-dungeon-sfx-pack
- Victory jingle sound effect: https://freesound.org/people/guillermochicasonido/sounds/691655/
- Defeat jingle sound effect: https://pixabay.com/ko/sound-effects/%EB%AE%A4%EC%A7%80%EC%BB%AC-game-over-orchestral-stinger-cartoon-defeat-546515/
- Menu music: https://freesound.org/people/FoolBoyMedia/sounds/264295/
