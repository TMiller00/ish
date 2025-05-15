# ish - A Simple Shell in Zig

🚧 **Work in Progress!** 🚧

This is still under active development. Things might break, change, or not work at all.

An attempt at building a basic Unix shell in Zig. It's based on Stephen Brennan's ["Write a Shell in C"](https://brennan.io/2015/01/16/write-a-shell-in-c/) tutorial, but using Zig's safety features and error handling.

## What it will do at some point

- Takes commands and runs them (like a very basic bash)
- Has a few built-in commands (cd, help, exit)

## Running it

```bash
zig build
./zig-out/bin/ish
```

## Roadmap

[] Add command history functionality
[] Implement tab completion
[] Add support for pipes and redirects
[] Improve error reporting
[] Add more built-in commands
[] Implement signal handling
[] Add support for environment variables
[] Enhance the line splitting to handle more complex syntax
[] Error handling enhancements - add more descriptive error messages and proper cleanup
[] Environment variable expansion
[] Implement cd with no args to go to home directory
[] Add more standard builtins (pwd, echo, etc)
[]  Add test cases for core functionality
[]  Refactor REPL logic into a separate module
[]  Implement signal handling for graceful termination
[]  Enhance line parsing with support for escaped quotes and better syntax
