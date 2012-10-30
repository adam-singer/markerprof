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

typedef void CaptureCallback(List events);
typedef void CaptureControlCallback(int command, String requester);

class ProfilerClient {
  static final int TypeUserApplication = 0x1;
  static final int TypeProfilerApplication = 0x2;

  static final int StartCapture = 0x1;
  static final int StopCapture = 0x2;
  WebSocket socket;
  String _name;
  CaptureCallback _onCapture;
  CaptureControlCallback _onCaptureControl;
  int _type;

  String get name => _name;

  ProfilerClient(this._name, this._onCapture, this._onCaptureControl, this._type) {

  }

  bool get connected {
    if (socket == null) {
      return false;
    }
    return socket.readyState == WebSocket.OPEN;
  }

  void _onMessage(messageEvent) {
    //print('Got ${messageEvent.data}');
    Map message = JSON.parse(messageEvent.data);
    String command = message['command'];
    if (command == 'identify') {
      var response = {
                      'command':'identity',
                      'name':name,
                      'type':_type
      };
      socket.send(JSON.stringify(response));
      return;
    }
    if (command == 'startCapture') {
      _onCaptureControl(StartCapture, message['requester']);
      return;
    }
    if (command == 'stopCapture') {
      _onCaptureControl(StopCapture, message['requester']);
      return;
    }
    if (command == 'deliverCapture') {
      _onCapture(message['payload']);
      return;
    }
  }

  void connect(String url) {
    socket = new WebSocket(url);
    socket.on.message.add(_onMessage);
  }

  void startCapture(String target) {
    print('startCapture $target');
    var response = {
                    'command':'startCapture',
                    'target':target
    };
    socket.send(JSON.stringify(response));
  }

  void stopCapture(String target) {
    var response = {
                    'command':'stopCapture',
                    'target':target
    };
    socket.send(JSON.stringify(response));
  }

  void deliverCapture(String target, List capture) {
    var response = {
                    'command':'deliverCapture',
                    'target':target,
                    'payload':capture,
    };
    socket.send(JSON.stringify(response));
  }
}
