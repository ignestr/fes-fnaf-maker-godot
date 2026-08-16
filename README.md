# Fazbear Entertainment Simulator (AKA FNAF Maker)
## A game built on Godot 4.7 where you build your own pizzerias based off the Five Nights at Freddy's series by Scott Cawthon, and spend playable, fully featured nightshifts inside.

This project is still pretty early in development, so some (not many) of the promises made here may not represent the current state of the project. However, they do reflect its eventual state as it progresses toward completion.

---
# Gameplay
The gameplay is mainly composed of two parts. The editor, where you make the pizzeria, and the nightshift, where you spend five nights in it.

## Editor (AKA Dayshift)
You start with an empty room, some tables, and a stage. From there you can choose to make a hallway, add animatronics, set up the cameras, and expand your pizzeria. With most of the items from the original games, along with a lot of brand-new content, you can decorate it however you want!

## Nightshift
After building your dream location, you can spend five (or more) nights using the mechanics you set up before. Every single feature and gameplay mechanic from the original titles is present with more options and all the more potential for making challenging nights. You can decide everything from the length of each individual night, to changing the pizzeria itself as each night progresses! This is designed to be as versatile as possible, so there is always room for innovation on how to connect all of these elements together.


# Technical description
This is a more in-depth description of the main systems the project hinges on. Not every system or implementation is mentioned here, as I want to focus on the most important aspects of how the game works. Systems or features that are yet to be implemented are not included.

## Data structure
The game uses a data oriented model for the pizzeria, where a central class (vox.gd) is always loaded and stores all of the building data as three dictionaries with coordinate keys to reduce memory overhead in place of two dimensional arrays. The project is designed to be highly performant, and as such it uses mostly bit packed classes to store pizzeria data, so complex layouts are very light both on RAM and on disk storage.

Walls are mainly composed of two bytes. The first one encodes a wall type and a set of flags, which through a look-up table can represent most types of wall devices found in the franchise. (eg. vents, windows, security doors)

## Physical building
Godot's CSG system is used to box out the walls and floor with the needed holes for vents / doors / windows.

Following the focus, the basic map geometry is built and rebuilt based on generated chunks in order to avoid full rebuilds as doing so often takes a few seconds for large pizzerias. Because this chunk division only concerns the building loop and the data structure is completely oblivious to it, chunk-edge problems do not exist. When editing, only the affected chunks are rebuilt, which results in a smooth gameplay experience.

For accessing and instancing wall scenes and materials, it uses an index (Devicedex and Materindex respectively) where a StringName ID refers to an entry that can be loaded on demand. For the case of Devicedex, it includes properties about how and where the model can be placed to make sure it will be rendered correctly.

## Editor
The editor uses a state machine to differentiate placing modes or behaviors. This area is very heavy on coordinate math, as it requires understanding a lot of the geometric proportions that go into arranging positions on the grid, as well as solving problems specific to this implementation.


# Special thanks
I would like to thank Scott Cawthon for making such an amazing series, and creating these characters and locations from nothing to begin with. This project would not have happened otherwise, and he deserves most of the credit for it.
