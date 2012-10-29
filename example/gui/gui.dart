import 'dart:html';
import 'package:marker_prof/profiler.dart';
import 'package:marker_prof/profiler_gui.dart';

ProfilerTree profilerTree;
num rotatePos = 0;
int frameCount = 0;
int frameCountToReset = 20;

int fib(int n) {
  if (n <= 1) {
    return 1;
  }
  return fib(n-1) + fib(n-2);
}

void animate(num time) {
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

  {
    Profiler.enter('A');
    Profiler.enter('B');
    Profiler.enter('C');
    Profiler.enter('D');
    Profiler.enter('E');
    Profiler.exit();
    Profiler.exit();
    Profiler.exit();
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
    var tbody = document.query('#profilerTable');
    ProfilerTreeTableGUI.fillTable(profilerTree, Profiler.frequency, tbody);
    // We reset the tree statistics for next build
    profilerTree.resetStatistics();
  }

}

void main() {
  Profiler.init();
  profilerTree = new ProfilerTree();
  window.requestAnimationFrame(animate);
}
