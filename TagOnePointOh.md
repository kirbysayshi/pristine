# 1.0: Dang... time to start over #
I started implementing this idea while learning Papervision3D (as well as 3D programming techniques in general...), and thus, while 1.0 is sort of feature rich, it's not viable to expand from here without a total rewrite. However, for those (if there are any) that want to just play around with something, it's a good way to do so.

Tag 1.0 is a Flex Builder 4 (Gumbo) project, so your best bet is to just import it there, and hit run. If you just try running the swf, you're going to get permissions errors, as it needs to load up assets from neighboring folders (like ship data, movie clip assets, etc).

If you just want to play it, try opening up the Flight.html file. I can't guarantee you won't get sandbox permission errors, but it's worth a shot. Eventually, I'll host this somewhere, just so people can see it without having to download it.

# Features #

Implemented and WORKING in this tag:
  * **Horizontal/Vertical Thrusters (Translation thrusters)**: in addition to the standard flying forward, you can use the WASD keys to thrust up/left/down/right. It's like strafing, but in space! Thrusting takes away power from the main engines, so you cannot fly at full speed and be thrusting at the same time.
  * **"Custom" Ships**: While the graphics are generic, custom ships can be loaded from an XML spec sheet located in the assets/shipdata folder. Editing the com/Flight/ThreeDee.as file constructor where the ship data is loaded will change the file that is loaded... current ships right now are "x-wing" and "viperMKII". Your best bet is to just edit the existing XML files to see what happens. Things to notice: you can have as many firepods as you want (points of fire), and they can be either automatic (gatling gun) or chained (x-wing style).
  * **Space Debris**: automatically generated, this gives the impression that you're actually moving.
  * **Handling**: You have better handling at 30% throttle than at 100% or 0%!
  * **HUGE Arena**: Yeah, this place is huge. I think overall, it's optimized fairly well, and runs on my Core2 Laptop with integrated intel at 30fps. Not bad!

Implemented and NOT WORKING in this tag:
  * **Gliding**: tapping the space bar toggles "drift" mode, where your engines are temporarily disengaged, yet forward momentum is conserved. So you can be flying one way, and shooting behind you! Unfortunately, there's a glitch/bug where firing is really messed up. But it's sort of there.

# Controls #

  * Throttle: 1/2/3 = 0%/30%/100% throttle respectively (1/2/3 above the keyboard, not the keypad), +/- increases/decreases gradually
  * Toggle Internal/External View: / (slash key next to right shift key)
  * Thrust: WASD... this is proportional to how much engine power you have! Thrusting at full throttle will decrease your speed...
  * Toggle deadzone marker: ' (single quote key) toggles the square that shows where the mouse must be to not change your attitude.
  * Toggle GLIDE/DRIFT: Space bar, explained above
  * Weapons: Click to shoot. No collision detection yet.

P.S. The space station in the distance is not super tiny, but just really far away. You'll get to it eventually!