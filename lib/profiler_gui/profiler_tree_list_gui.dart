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

class ProfilerTreeListGUI {
  static UListElement buildNode(ProfilerTreeNode node, int totalTicks, int frequency) {
    UListElement list = new UListElement();
    for (ProfilerTreeNode child in node.children) {
      if (child.enterCount == 0) {
        continue;
      }
      LIElement item = new LIElement();
      ParagraphElement p = new ParagraphElement();
      {
        int microsecondFrequency = frequency ~/ 1000000;
        // average across call counts
        int inclusiveTime = child.inclusiveTicks~/child.enterCount;
        int exclusiveTime = child.exclusiveTicks~/child.enterCount;
        // determine microseconds
        inclusiveTime ~/= microsecondFrequency;
        exclusiveTime ~/= microsecondFrequency;
        int inclusivePercent = (child.inclusiveTicks * 100) ~/ node.inclusiveTicks;
        int exclusivePercent = (child.exclusiveTicks * 100) ~/ totalTicks;
        p.innerHTML = '${child.name} I: ${inclusiveTime} µs ${inclusivePercent} % E: ${exclusiveTime} µs ${exclusivePercent} %';
      }
      item.nodes.add(p);
      if (child.children.length > 0) {
        item.nodes.add(buildNode(child, totalTicks, frequency));
      }
      list.nodes.add(item);
    }
    return list;
  }
  
  static UListElement buildTree(ProfilerTree tree, int frequency) {
    UListElement root = new UListElement();
    LIElement item = new LIElement();
    ParagraphElement p = new ParagraphElement();
    p.innerHTML = '<p>Root</p>';
    item.nodes.add(p);
    Element r = buildNode(tree.root, tree.root.inclusiveTicks, frequency);
    if (r != null) {
      item.nodes.add(r);
    }
    root.nodes.add(item);
    return root;
  }
}

class ProfilerTreeTableGUI {
  static TableCellElement makeCell(String text,int margin) {
    var e = new TableCellElement();
    e.innerHTML = '<p style="margin-left: ${margin}px">$text</p>';
    return e;
  }
  
  static void _buildNode(ProfilerTreeNode node, int depth, int totalTicks, int frequency, TableElement table) {    
    UListElement list = new UListElement();
    for (ProfilerTreeNode child in node.children) {
      if (child.enterCount == 0) {
        continue;
      }
      TableRowElement item = new TableRowElement();
      {
        int microsecondFrequency = frequency ~/ 1000000;
        // average across call counts
        int inclusiveTime = child.inclusiveTicks~/child.enterCount;
        int exclusiveTime = child.exclusiveTicks~/child.enterCount;
        // determine microseconds
        inclusiveTime ~/= microsecondFrequency;
        exclusiveTime ~/= microsecondFrequency;
        int inclusivePercent = (child.inclusiveTicks * 100) ~/ node.inclusiveTicks;
        int exclusivePercent = (child.exclusiveTicks * 100) ~/ totalTicks;
        item.nodes.add(makeCell(child.name, depth * 5));
        item.nodes.add(makeCell('$inclusiveTime µs', 0));
        item.nodes.add(makeCell('${inclusivePercent} %', 0));
        item.nodes.add(makeCell('${exclusiveTime} µs', 0));
        item.nodes.add(makeCell('${exclusivePercent} %', 0));
      }
      table.nodes.add(item);
      if (child.children.length > 0) {
        _buildNode(child, depth+1, totalTicks, frequency, table);
      }
    }
  }
  
  static TableElement buildTree(ProfilerTree tree, int frequency) {
    var root = new TableElement();
    TableRowElement header = new TableRowElement();
    header.nodes.add(makeCell('Marker Name', 0));
    header.nodes.add(makeCell('Inclusive Time', 0));
    header.nodes.add(makeCell('Inclusive Percentage', 0));
    header.nodes.add(makeCell('Exclusive Time', 0));
    header.nodes.add(makeCell('Exclusive Percentage', 0));
    root.nodes.add(header);
    _buildNode(tree.root, 0, tree.root.inclusiveTicks, frequency, root);
    return root;
  }
}