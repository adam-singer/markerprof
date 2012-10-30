import 'dart:html';
import 'package:marker_prof/profiler.dart';
import 'package:marker_prof/profiler_client.dart';
import 'package:marker_prof/profiler_gui.dart';

ProfilerClient profilerClient;
ProfilerTree profilerTree;
Element profilerTable;
int frameCount = 0;
int frameCountToReset = 20;

void onCapture(List events) {
  print('event');
  frameCount++;

  if (frameCount > frameCountToReset) {
    profilerTree.processRemoteEvents(events);
    ProfilerTreeTableGUI.fillTable(profilerTree, Profiler.frequency, profilerTable);
    profilerTree.resetStatistics();
  }
}

void onCaptureControl(int command, String requester) {
  print('${command} from ${requester}');
}

void main() {
  Profiler.init();

  profilerTable = document.query('#profilerTable');

  profilerClient = new ProfilerClient(
    'Client',
    onCapture,
    onCaptureControl,
    ProfilerClient.TypeProfilerApplication
  );

  profilerClient.connect('ws://127.0.0.1:8087');

  profilerTree = new ProfilerTree();
}
