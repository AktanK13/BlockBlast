// Import necessary packages
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const BlockBlastGame());
}

class BlockBlastGame extends StatelessWidget {
  const BlockBlastGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Block Blast Clone',
      home: MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Blast Clone'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
              child: const Text('Начать игру'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int gridSize = 8;
  static const double cellSize = 40.0;
  static const List<Color> blockColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  List<List<Color?>> grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
  List<List<List<int>>> nextBlocks = [];
  Color? currentDraggingColor;
  List<List<int>>? currentDraggingBlock;

  @override
  void initState() {
    super.initState();
    initializeGrid();
    generateNextBlocks();
  }

  void initializeGrid() {
    final random = math.Random();
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (random.nextDouble() < 0.1) {
          var block = generateBlockShape(random.nextInt(8));
          if (canPlaceBlock(block, row, col)) {
            placeBlock(block, row, col, blockColors[random.nextInt(blockColors.length)]);
          }
        }
      }
    }
  }

  void generateNextBlocks() {
    final random = math.Random();
    nextBlocks = List.generate(3, (_) {
      int blockType = random.nextInt(5);
      return generateBlockShape(blockType);
    });
  }

  List<List<int>> generateBlockShape(int type) {
    switch (type) {
      case 0:
        return [
          [1, 1, 1],
        ];
      case 1:
        return [
          [1],
          [1],
          [1],
        ];
      case 2:
        return [
          [1, 1],
          [1, 1],
        ];
      case 3:
        return [
          [1, 0],
          [1, 1],
        ];
      case 4:
        return [
          [0, 1],
          [1, 1],
        ];
      case 5:
        return [
          [1, 1],
          [1, 0],
          [1, 0],
        ];
      case 6:
        return [
          [1, 0],
          [1, 0],
          [1, 1],
        ];
      case 7:
        return [
          [0, 1],
          [0, 1],
          [1, 1],
        ];
      case 8:
        return [
          [1, 1],
          [0, 1],
          [0, 1],
        ];
      case 9:
        return [
          [1, 0, 0],
          [1, 1, 1],
        ];
      case 10:
        return [
          [1, 1, 1],
          [1, 0, 0],
        ];
      case 11:
        return [
          [0, 0, 1],
          [1, 1, 1],
        ];
      case 12:
        return [
          [1, 1, 1],
          [0, 0, 1],
        ];
      default:
        return [];
    }
  }

  Widget buildBlock(List<List<int>> shape, Color color, {bool isGridBlock = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: shape.where((row) => row.any((cell) => cell == 1)).map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((cell) {
            return Container(
              width: cellSize,
              height: cellSize,
              color: cell == 1 ? color : (isGridBlock ? Colors.blue : Colors.transparent),
              margin: const EdgeInsets.all(1),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  bool canPlaceBlock(List<List<int>> block, int row, int col) {
    log('data- $block');
    log('data- $row');
    log('data- $col');
    for (int r = 0; r < block.length; r++) {
      for (int c = 0; c < block[r].length; c++) {
        if (block[r][c] == 1) {
          int gridRow = row + r;
          int gridCol = col + c;
          if (gridRow >= gridSize || gridCol >= gridSize || grid[gridRow][gridCol] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placeBlock(List<List<int>> block, int row, int col, Color color) {
    setState(() {
      for (int r = 0; r < block.length; r++) {
        for (int c = 0; c < block[r].length; c++) {
          if (block[r][c] == 1) {
            grid[row + r][col + c] = color;
          }
        }
      }
      nextBlocks.remove(currentDraggingBlock);
      currentDraggingBlock = null;
      currentDraggingColor = null;
      if (nextBlocks.isEmpty) {
        generateNextBlocks();
      }
      clearFullLines();
      if (!hasValidMove()) {
        showGameOverDialog();
      }
    });
  }

  void clearFullLines() {
    setState(() {
      for (int row = 0; row < gridSize; row++) {
        if (grid[row].every((cell) => cell != null)) {
          grid[row] = List.generate(gridSize, (_) => null);
        }
      }

      for (int col = 0; col < gridSize; col++) {
        if (List.generate(gridSize, (row) => grid[row][col]).every((cell) => cell != null)) {
          for (int row = 0; row < gridSize; row++) {
            grid[row][col] = null;
          }
        }
      }
    });
  }

  bool hasValidMove() {
    for (var block in nextBlocks) {
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          if (canPlaceBlock(block, row, col)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Игра окончена!'),
        content: const Text('Нет доступных ходов.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Назад в меню'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Blast Clone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  int row = index ~/ gridSize;
                  int col = index % gridSize;
                  return DragTarget<List<List<int>>>(
                    onWillAcceptWithDetails: (details) {
                      final draggedBlock = details.data;
                      return canPlaceBlock(draggedBlock, row, col);
                    },
                    onAcceptWithDetails: (details) {
                      final draggedBlock = details.data;
                      if (currentDraggingColor != null) {
                        placeBlock(draggedBlock, row, col, currentDraggingColor!);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        color: grid[row][col] ?? Colors.grey[300],
                        child: const SizedBox.expand(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: nextBlocks.map((block) {
                final color = blockColors[nextBlocks.indexOf(block) % blockColors.length];
                return Draggable<List<List<int>>>(
                  data: block,
                  feedback: Material(
                    color: Colors.transparent,
                    child: buildBlock(block, color),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: buildBlock(block, color),
                  ),
                  onDragStarted: () {
                    setState(() {
                      currentDraggingBlock = block;
                      currentDraggingColor = color;
                    });
                  },
                  onDragEnd: (_) {
                    setState(() {
                      currentDraggingBlock = null;
                      currentDraggingColor = null;
                    });
                  },
                  child: buildBlock(block, color),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
