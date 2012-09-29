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
  
  static int get frequency => _watch.frequency();
  
  static enter(String name) {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.Enter, name, _watch.elapsed());
    events.add(event);
  }
  
  static exit() {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.Exit, null, _watch.elapsed());
    events.add(event);
  }
  
  static frameStart() {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.FrameStart, 'Frame $frameCounter', _watch.elapsed());
    events.add(event);
  }
  
  static frameEnd() {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.FrameEnd, 'Frame $frameCounter', _watch.elapsed());
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