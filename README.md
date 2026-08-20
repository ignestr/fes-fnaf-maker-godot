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

---
# Roadmap
This is a rough layout of how I plan to structure development for the game, but it is very subject to change as challenges arise and shape the creative process.

## Demo 1 (MVP) (In Progress):
This will focus on getting the main gameplay down, with good controls and feature completeness for recreating FNAF 1.
It includes the three main systems of Rendering, Editing, and the Nightshift, as well as the content from FNAF 1 with enough polish to be enjoyable.

## Demo 2 (FNAF 2 Update) (Not started):
This update is based around finishing up the necessary polish/fixes from the MVP, refactoring and documenting old code, as well as adding the rest of the basic features that might've been too expansive for the first demo (eg. the vent system, office interactions like the flashlight, a logging system, or setting up "fangame" structures)
Along with the basic expansions and fixes, each update is focused on implementing subsequent entries in the series, so most features and content will be directed at adding all features, items and animatronics from FNAF 2.

## Demo 3 (FNAF 3 Update) (Not fully conceptualized):
This update is mostly focused on laying the foundations for the full version of the device and monitor system that will be required for some of the more complex mechanics that later entries introduce. To put it simply, because the FNAF 3 includes the maintenance panel, I intend to add a framework that allows you to create things similar to it yourself, where it can be connected to other gameplay elements outside of "fixing a system". (Also, expanding the device system to allow for "breaking", needing to reset, etc) Because from here on out the franchise breaks its formula quite strongly and features all sorts of camera / panel related mechanics, laying the first foundations for this early on is important.
Outside of the cameras and panel, most of the remaining gameplay aspects are covered by the previous demo (although not all). Like the others it will aim to add all content and gameplay mechanics from FNAF 3

## Version 1.0 (FNAF 4 Update) (Not fully conceptualized):
This update marks version 1.0 as the following three updates will take a very extended amount of time to complete each, and it's meant to be able to stand on its own for a while. It will add all content and mechanics from FNAF 4, as well as original content and a heavy focus on polish. It will allow for creating custom animatronic AI based on logical nodes to represent behaviors more complex than following a linear path.

## Beyond
The last four updates aren't mentioned mostly because:
- Sister Location's gameplay requires implementing a lot of completely brand new systems and re-contextualizes a lot of old code. Because the point is not only to be able to recreate any of the games, but to twist their mechanics and use them as modules, the update entails expanding all aspects of the game, and heavy refactors.
- Pizzeria Simulator has a very large amount of content and assets that would have to be brought over, although mechanically most of the foundations for it were established before.
- Ultimate Custom Night's roadmap is heavily dependent on the state of the project after the last two updates, as it both has a lot of content and introduces new mechanics that may not have been fully covered in the past.
- After this, I intend to add a story mode following an alternate timeline, as well as the ability to make modular animatronics, being the final major content update, but this isn't guaranteed.

---
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
