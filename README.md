# TFA Bullet Ballistics
**TFA Bullet Ballistics** is a full ballistics system in Garry's Mod for [TFA Base](https://steamcommunity.com/sharedfiles/filedetails/?id=415143062). Instead of firing hitscan bullets that require no skill at all, you can instead shoot bullets impacted by gravity, etc. I tried to optimize it as well as I could with my knowledge, all calculations regarding bullets are done serverside. If you would like a feature you can request it [here](https://github.com/Daxble/TFA-Bullet-Ballistics/issues) or make it yourself and submit it [here](https://github.com/Daxble/TFA-Bullet-Ballistics/pulls).

# Features

* Should work with all bullet based weapons
* All bullets calculated serverside
* Bullet Drop
* Scales with gravity ( Above 0 )
* Wind ( If StormFox is installed )
* Tracers
* Bullet Cracks

# FAQ
Q. It doesn't seem like it's working up close?  
A. Hitscan bullets are used on shots less than 1000 source units ( ~19.5 Meters ), this prevents unnecessary strain on the server from close range gun fights.

___

Q. Why are the bullets so fast  
A. This aims to simulate real bullets, not Battlefield bullets.  
**Kar98K: Muzzle velocity = 760m/s, 300m shot, distance/velocity = 0.39 seconds to hit**

___

Q. Why isn't my weapon using the bullets?  
A. You need to do the setup for **Every** weapon that needs ballistics

# Server Owners / Singleplayer

1. Download the addon as a zip  
2. Extract the *TFA-Bullet-Ballistics-master* folder to your addons folder  
3. Install [StormFox](https://steamcommunity.com/sharedfiles/filedetails/?id=1132466603) if you want wind to affect bullets  

* **This is assuming you already have weapons that require this, if you do not please continue below.**  
* **Players will need to download the sounds**

# SWEP Developers

1. Download the addon as a zip
2. Extract the *TFA-Bullet-Ballistics-master* folder to your addons folder

**The following steps need to be completed for each weapon that will use ballistics**

3. Change the SWEP base to "tfa_ballistic_base"
```lua
SWEP.Base = "tfa_ballistic_base"
```
4. Place the following lines somewhere in your weapon
```lua
SWEP.Primary.Velocity = 760 // Weapon's muzzle velocity in meters, change to whatever you would like. ( Defaults to 500 )
SWEP.TracerColor = Color( 255, 0, 0, 255 ) // Choose whatever color you would like, set alpha to zero to disable. ( Shotguns shouldn't have tracers ever. )
```

That's all you have to do to get this up and running! Do not use on projectile based weapons such as grenades or rockets, they will just shoot bullets instead.

# To Do
1. Fix bugs ( Always in Progress )
2. Add wind system ( Using StormFox )
3. Proper bullet drop using verlet integration ( Done )

# Bugs
* None Currently

Please report other bugs [here](https://github.com/Daxble/TFA-Bullet-Ballistics/issues) if possible.

# Credits
TFA - Helping with bullet drop and velocity code  
YuRaNnNzZZ - Extensive testing and a lot help.  
Kiwi, elwolf6, Amisaddai - FPS benchmarking  
Matsilagi - Various help  
Daxble - Coding this thing  

# License

**TFA Bullet Ballistics is licensed under the GNU General Public License v3.0**

| **Can**  | **Cannot** | **Must** |
| ------------- | ------------- | ------------- |
| Commercial Use  | Sublicense  | Include Original*  |
| Modify  | Hold Liable  | State Changes*  |
| Distribute  |   | Disclose Source*  |
| Place Warranty  |   | Include License  |
| Use Patent Claims  |   | Include Copyright  |
| Modify  |   | Include Install Instructions  |

**Include Original:** You must include a link to this page or a copy of the code itself.

**State Changes:** You must state **significant** changes made to the code.

**Disclose Source:** You must expose all source code to all users.
