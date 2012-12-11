# Marker Profiler #

## Introduction ##

Markerprof is a User Marker Based Profiler for Dart.

You instrument code paths with calls to 



## Status: Beta ##

Profiling works and there is a simple GUI that you can embed.
Profiling remote applications over WebSocket is still a work in progress.


## Getting Start ##

Create a Dart project and add the following to **pubspec.yaml**


```
dependencies:
    markerprof:
        git: https://github.com/johnmccutchan/markerprof.git
```

and run **pub install** to install **marker_prof** (including its dependencies).

## Example ##

```
#import('package:marker_prof/profiler.dart');

Profiler.enter('Scope Name');
// Code
Profiler.exit();

```
