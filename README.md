# TFA Bullet Ballistics
**TFA Bullet Ballistics** is a full ballistics system in Garry's Mod for [TFA Base](https://steamcommunity.com/sharedfiles/filedetails/?id=415143062). Instead of firing hitscan bullets, you can instead shoot bullets impacted by gravity, wind, etc. It's fairly well optimized considering the complexity of the addon. If you would like a feature you can request it [here](https://github.com/Daxble/TFA-Bullet-Ballistics/issues) or make it yourself and submit it [here](https://github.com/Daxble/TFA-Bullet-Ballistics/pulls).

# Features

* Should work with all TFA weapons.
* All bullets calculated serverside
* Bullet Drop
* Scales with gravity ( Above 0 )
* Wind ( If StormFox is installed )
* Tracers
* Bullet Cracks
* Weapons automatically patched.

# FAQ
Q. It doesn't seem like it's working up close?  
A. Hitscan bullets are used on shots less than 1000 source units ( ~19.5 Meters ), this prevents unnecessary strain on the server from close range gun fights.

___

Q. Why are the bullets so fast  
A. This aims to simulate real bullets, not Battlefield bullets.  
**Kar98K: Muzzle velocity = 760m/s, 300m shot, distance/velocity = 0.39 seconds to hit**

___

Q. Why isn't my weapon using the bullets?  
A. The patcher didn't pick up the weapon, please report the weapon to us and we will try and fix it.

# Server Owners / Singleplayer

1. Download the addon as a zip  
2. Extract the *TFA-Bullet-Ballistics-master* folder to your addons folder  
3. Install [StormFox](https://steamcommunity.com/sharedfiles/filedetails/?id=1132466603) if you want wind to affect bullets  

* **Players will need to download the sounds from the server or workshop.**

# To Do
1. Fix bugs ( Always in Progress )
2. Add wind system ( Using StormFox )
3. Proper bullet drop using verlet integration ( Done )
4. Patcher ( Done )
5. Workshop ( Done )

# Bugs
* None Currently

Please report other bugs [here](https://github.com/Daxble/TFA-Bullet-Ballistics/issues) if possible.

# Credits
Daxble - Coding this thing  
YuRaNnNzZZ - Patcher code, extensive testing, and a lot help.  
TFA - Helping with bullet drop and velocity code  
Matsilagi - Various help  
Kiwi, elwolf6, Amisaddai - FPS benchmarking  

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
