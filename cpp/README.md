# AutoUtils.dll

the dll which is used in an embedded AutoIt String and will be auto loaded on startup.

If you want to build it yourself, this is the place to do so.
Even tho cmake is very common, i know a lot are sturggling with it.
So i made 3 simple .bat files to help you.

```
Build.bat
```

This will generate your c++ environment in **visual studio 17**.
Use this later when you add or remove files from the project, to update the solution. Make sure to save before running.

```
Open.bat
```

This opens the solution, no magic

```
Compile.bat
```

And this builds the dll files. Dlls will be found in the root folder /tools for compressing them.
