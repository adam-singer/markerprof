#import('dart:html');
#import('package:markerprof/profiler.dart');
#import('package:markerprof/profiler_gui.dart');

ProfilerTree profilerTree;
num rotatePos = 0;
int frameCount = 0;
int frameCountToReset = 10;

int fib(int n) {
  if (n <= 1) {
    return 1;
  }
  return fib(n-1) + fib(n-2);
}

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
  
  {
    Profiler.enter('Work update');
    Profiler.enter('fib(4)');
    fib(4);
    Profiler.exit();
    Profiler.enter('fib(8)');
    fib(8);
    Profiler.exit();
    Profiler.exit();
  }
  
  window.requestAnimationFrame(animate);
  Profiler.exit();
  
  // Process the profiler events every frame 
  profilerTree.processEvents(Profiler.events);
  // Clear them for next frame
  Profiler.clear();
  
  // Every frameCountToReset we rebuild the GUI
  if (frameCount > frameCountToReset) {
    frameCount = 0;
    var guiTree = ProfilerTreeTableGUI.buildTree(profilerTree, Profiler.frequency);
    //var guiTree = ProfilerTreeListGUI.buildTree(profilerTree, Profiler.frequency);
    var div = document.query('#profiler');
    div.nodes.clear();
    div.nodes.add(guiTree);
    
    // We reset the tree statistics for next build
    profilerTree.resetStatistics();
  }
  
}

void main() {
  Profiler.init();
  profilerTree = new ProfilerTree();
  window.requestAnimationFrame(animate);
}
