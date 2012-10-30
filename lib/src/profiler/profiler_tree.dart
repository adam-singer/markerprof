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

class ProfilerTreeNode {
  ProfilerTreeNode parent;
  List<ProfilerTreeNode> children;
  String name;
  int enterCount;
  int inclusiveTicks;
  int exclusiveTicks;

  ProfilerTreeNode(this.parent, this.name) {
    this.enterCount = 0;
    this.inclusiveTicks = 0;
    this.exclusiveTicks = 0;
    children = new List<ProfilerTreeNode>();
  }

  ProfilerTreeNode findChild(String childName) {
    for (ProfilerTreeNode child in children) {
      if (child.name == childName) {
        return child;
      }
    }
    return null;
  }

  ProfilerTreeNode findOrAddChild(String childName) {
    ProfilerTreeNode child = findChild(childName);
    if (child != null) {
      return child;
    }
    child = new ProfilerTreeNode(this, childName);
    children.add(child);
    return child;
  }

  void resetStatistics() {
    enterCount = 0;
    inclusiveTicks = 0;
    exclusiveTicks = 0;
    for (ProfilerTreeNode child in children) {
      child.resetStatistics();
    }
  }
}

class ProfilerTree {
  int _firstTime;
  int _lastTime;
  ProfilerTree() {
    root = new ProfilerTreeNode(null, 'Root');
    _firstTime = 0;
    _lastTime = 0;
  }

  int get firstTime => _firstTime;
  int get lastTime => _lastTime;

  ProfilerTreeNode root;

  void clear() {
    root.children.clear();
  }

  void resetStatistics() {
    _firstTime = 0;
    _lastTime = 0;
    root.resetStatistics();
  }

  int _processEvent(Queue<ProfilerEvent> events,
                    ProfilerTreeNode parent, int enterTime) {
    int timeInChild = 0;
    while (events.length > 0) {
      ProfilerEvent event = events.first;
      events.removeFirst();

      // Keep track of global timestamps
      if (_firstTime == 0) {
        _firstTime = event.now;
      }
      if (event.now > _lastTime) {
        _lastTime = event.now;
      }

      // Push
      if (event.event == ProfilerEvent.Enter) {
        ProfilerTreeNode childNode = parent.findOrAddChild(event.name);
        childNode.enterCount++;
        int childExitTime = _processEvent(events, childNode, event.now);
        assert(childExitTime >= event.now);
        timeInChild += childExitTime - event.now;
      }

      // Pop
      if (event.event == ProfilerEvent.Exit) {
        //assert(enterTime != 0);
        int totalTime = event.now - enterTime;
        parent.inclusiveTicks += totalTime;
        parent.exclusiveTicks += totalTime - timeInChild;
        return event.now;
      }
    }
    if (enterTime != 0) {
      print('Warning ran out of events inside node ${parent.name}');
      print('Look for unmatched enter and exit pairs.');
    }
    return enterTime;
  }

  void processEvents(Queue<ProfilerEvent> events) {
    _processEvent(events, root, 0);
    int totalTime = _lastTime - _firstTime;
    root.inclusiveTicks += totalTime;
    int timeInChild = 0;
    for (ProfilerTreeNode childNode in root.children) {
      timeInChild += childNode.inclusiveTicks;
    }
    root.exclusiveTicks += totalTime - timeInChild;
  }

  void processRemoteEvents(List remoteEvents) {
    Queue<ProfilerEvent> events = new Queue<ProfilerEvent>();
    for (Map remoteEvent in remoteEvents) {
      ProfilerEvent event = new ProfilerEvent(remoteEvent['event'], remoteEvent['name'], remoteEvent['now']);
      events.add(event);
    }
    processEvents(events);
  }
}
