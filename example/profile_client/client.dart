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
  frameCount++;

  profilerTree.processRemoteEvents(events);

  if (frameCount >= frameCountToReset) {
    ProfilerTreeTableGUI.fillTable(profilerTree, Profiler.frequency, profilerTable);
    profilerTree.resetStatistics();
    frameCount = 0;
  }
}

void onCaptureControl(int command, String requester) {

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
