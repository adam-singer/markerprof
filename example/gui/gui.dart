#import('dart:html');
#import('package:markerprof/profiler.dart');
#import('package:markerprof/profiler_gui.dart');

ProfilerTree profilerTree;
num rotatePos = 0;
int frameCount = 0;
int frameCountToReset = 10;

bool animate(int time) {
  frameCount++;
  Profiler.enter('animate');
  
  {
    Profiler.enter('text animation update');
    var textElement = query("#text");
    textElement.style.transform = "rotate(${rotatePos}deg)";
    rotatePos++;
    Profiler.exit();
  }
  
  window.requestAnimationFrame(animate);
  Profiler.exit();
  profilerTree.processEvents(Profiler.events);
  Profiler.clear();
  
  if (frameCount > frameCountToReset) {
    frameCount = 0;
    var guiTree = ProfilerTreeTableGUI.buildTree(profilerTree, Profiler.frequency);
    //var guiTree = ProfilerTreeListGUI.buildTree(profilerTree, Profiler.frequency);
    var div = document.query('#profiler');
    if (div != null) {
      div.nodes.clear();
      div.nodes.add(guiTree);
    }
    profilerTree.resetStatistics();
  }
  
}

void main() {
  Profiler.init();
  profilerTree = new ProfilerTree();
  window.requestAnimationFrame(animate);
}
