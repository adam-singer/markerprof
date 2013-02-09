/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/
part of profiler;

class ProfilerEvent {
  static const int Enter = 0x1;
  static const int Exit = 0x2;
  static const int FrameStart = 0x3;
  static const int FrameEnd = 0x4;
  int event;
  String name;
  int now;

  ProfilerEvent(this.event, this.name, this.now);

  Map serialize() {
    var response = {
                    'event':event,
                    'name':name,
                    'now':now,
    };
    return response;
  }
}

class Profiler {
  static Stopwatch _watch;
  static init() {
    _watch = new Stopwatch();
    _watch.start();
    events = new Queue<ProfilerEvent>();
    frameCounter = 0;
  }

  static int frameCounter;
  static Queue<ProfilerEvent> events;

  static int get frequency => _watch.frequency;

  static enter(String name) {
    if (_watch == null) {
      return;
    }
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.Enter, name, _watch.elapsedTicks);
    events.add(event);
  }

  static exit() {
    if (_watch == null) {
      return;
    }
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.Exit, null, _watch.elapsedTicks);
    events.add(event);
  }

  static frameStart() {
    if (_watch == null) {
      return;
    }
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.FrameStart, 'Frame $frameCounter', _watch.elapsedTicks);
    events.add(event);
  }

  static frameEnd() {
    if (_watch == null) {
      return;
    }
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.FrameEnd, 'Frame $frameCounter', _watch.elapsedTicks);
    events.add(event);
    frameCounter++;
  }

  static List makeCapture() {
    List<Map> capture = new List<Map>();
    for (ProfilerEvent pe in events) {
      capture.add(pe.serialize());
    }
    return capture;
  }

  static clear() {
    events.clear();
  }
}
