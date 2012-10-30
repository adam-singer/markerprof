import 'dart:html';
import 'package:marker_prof/profiler.dart';
import 'package:marker_prof/profiler_client.dart';

ProfilerClient profilerClient;
num rotatePos = 0;
int frameCount = 0;
int frameCountToReset = 20;

// Increase the numbers to increase the calculation time
// Maximum is around 32
int fibOne = 24;
int fibTwo = 32;

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
  if (profilerClient.connected) {
    profilerClient.deliverCapture('Client', Profiler.makeCapture());
  }

  // Clear them for next frame
  Profiler.clear();
}

void onCapture(List events) {

}

void onCaptureControl(int command, String requester) {

}

void main() {
  Profiler.init();

  profilerClient = new ProfilerClient(
    'Server',
    onCapture,
    onCaptureControl,
    ProfilerClient.TypeProfilerApplication
  );

  profilerClient.connect('ws://127.0.0.1:8087');

  window.requestAnimationFrame(animate);
}
