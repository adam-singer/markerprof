import 'dart:html';
import 'package:marker_prof/profiler.dart';
import 'package:marker_prof/profiler_gui.dart';

ProfilerTree profilerTree;
TableSectionElement profilerTable;
num rotatePos = 0;
int frameCount = 0;
int frameCountToReset = 20;

// Increase the numbers to increase the calculation time
// Maximum is around 32
int fibOne = 4;
int fibTwo = 8;

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
    Profiler.enter('fib(${fibOne})');
    fib(fibOne);
    Profiler.exit();
    Profiler.enter('fib(${fibTwo})');
    fib(fibTwo);
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
  if (frameCount >= frameCountToReset) {
    frameCount = 0;
    ProfilerTreeTableGUI.fillTable(profilerTree, Profiler.frequency, profilerTable);
    // We reset the tree statistics for next build
    profilerTree.resetStatistics();
  }

}

void main() {
  Profiler.init();
  profilerTable = document.query('#profilerTable') as TableSectionElement;
  profilerTree = new ProfilerTree();
  window.requestAnimationFrame(animate);
}
