# GreenstackJ's LöveJam 2022 Entry
_Magna and Dude_ (working title) is a game about a dude named Richter seeking to
save his his sister, Magna. To do so, Richter must learn to use his family's
magic to defeat dozens of monsters to delve deeper into the Fissure Dungeon.

## Installation
Requires Love 11.4. The .vscode folder has settings to make running and
debugging easier; the info for how to set this up is available [here][SheepArticle].
(You only need to install the listed extensions for the time being.)

Clone the repo with the `--recursive` flag.

## Gameplay
This is more of a wishlist than anything. If the brackets have a ✔ next
to it, then it's implemented! If it has an ❌, then it's not.

- ❌ Quakes:
	- ❌ If enemies hit something from the push, they take damage
	- ❌ Hold down the quake button to charge up a bigger and more powerful quake
	- ❌ Stronger quakes cause more damage to the level
		- ❌If the level takes too much damage, the level "collapses" and it's game
		over
- ❌ Quake types:
	- ❌ Standard:
		- ❌ No cooldown
		- ❌ Just pushes enemies away
		- ❌ Can destroy some structures
	- ❌ Volcano:
		- ❌ Moderate cooldown
		- ❌ Sets enemies on fire, which deals damage over time
	- ❌ Mountain:
		- ❌ Long cooldown
		- ❌ Hits flying enemies
		- ❌ Stuns all enemies it hits

## Thanks/Credits
[Tesselode/Baton][Baton] (Input library)  
[novemberisms/Brinevector][Brinevector] (Vector math library)  
[Sheepollution's Article on Setting up VSCode with Love2D][SheepArticle]

[Baton]: https://github.com/tesselode/baton
[Brinevector]: https://github.com/novemberisms/brinevector
[SheepArticle]: https://www.sheepolution.com/learn/book/bonus/vscode
