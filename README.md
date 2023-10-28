# fusgato-v1

Here is an earlier (half-working) version of FusGato, my Lua obfuscator. As I am unlikely to ever use this version in production, I have uploaded it in order to help people learn the processes behind an obfuscator in a language accessible to those who want to obfuscate it (students of Lua obfuscation can study processes in Lua, rather than a less accessible language like C#). It uses virtualisation to protect code, running it through a regular bytecode interpreter after some internal obfuscation techniques have been applied, and then the code is minified using [luasrcdiet](https://github.com/jirutka/luasrcdiet). These obfuscations can be seen in the `/bytecode/` directory, and the final script generator is under `/vm/`.

## Setup
The entire project runs on [Luvit](https://luvit.io/), and you can install it from their site. Then, you can just add your script to `/input/input.lua` and run the command `luvit main.lua` to run the obfuscator.

The obfuscator is in debug mode right now, which means that running `main.lua` will create 2 files, `nomin.lua` and `output.lua`, a non-minified version of the output and the final output respectively. 

## Extras
In `/resources/`, the file `strings.json` is a file where you can add a variety of your own meme strings, and the obfuscator is able to insert them into the output script. 

`interpreter.lua` is the quick interpreter that I made, pairing up with disassembled bytecode from `/bytecode/deserialize.lua` to interpret bytecode chunks. It is not fully working as the CLOSE opcode implementation is not yet there, but it should work (if not a little slowly) for all of the other opcodes.

Additionally, a PDF of the final write-up which I created is available in the repository under `lua_internals.pdf`. You can follow this alongside the source code to help clear up how everything works, as although I have tried to comment my code and keep it readable, I understand how hard it is sometimes to actually understand other people's code - even my own work I sometimes struggle to follow!

## Help/Support
If you would like any help on this subject, I am available to give tips and explain anything that I might have poorly explained. My discord server is available to join [here](https://discord.gg/cWQAy6Z697).
