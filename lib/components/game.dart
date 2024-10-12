import 'dart:async';
import 'dart:math';    

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:flutter/material.dart';

import 'background.dart';
import 'enemy.dart';
import 'ground.dart'; 
import 'player.dart'; 

class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame()
      : super(
          gravity: Vector2(0, 10),
          camera: CameraComponent.withFixedResolution(width: 1200, height: 600),
        );

  late final XmlSpriteSheet aliens;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet tiles;

  @override
  FutureOr<void> onLoad() async {
    final backgroundImage = await images.load('colored_grass.png');
    final spriteSheets = await Future.wait([
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_aliens.png',
        xmlPath: 'spritesheet_aliens.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_elements.png',
        xmlPath: 'spritesheet_elements.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_tiles.png',
        xmlPath: 'spritesheet_tiles.xml',
      ),
    ]);

    aliens = spriteSheets[0];
    elements = spriteSheets[1];
    tiles = spriteSheets[2];
    print(aliens);print('teststss');
    await world.add(Background(sprite: Sprite(backgroundImage)));
    await addGround();  
    await addPlayer();  
    unawaited( addEnemies());

    return super.onLoad();
  }
  Future<void> addGround() {                               // Add from here...
    return world.addAll([
      for (var x = camera.visibleWorldRect.left;
          x < camera.visibleWorldRect.right + groundSize;
          x += groundSize)
        Ground(
          Vector2(x, (camera.visibleWorldRect.height - groundSize)/2 ),
          tiles.getSprite('grass.png'),
        ),
    ]);
  }
  final _random = Random();                                // Add from here...

  Future<void> addPlayer() async => world.add(             // Add from here...
        Player(
          Vector2(camera.visibleWorldRect.left * 1.5 / 3, 0),
          aliens.getSprite(PlayerColor.randomColor.fileName),
        ),
      );

  @override
  void update(double dt) {


    super.update(dt);
    if (isMounted &&                                       // Modify from here...
        world.children.whereType<Player>().isEmpty &&
        world.children.whereType<Enemy>().isNotEmpty) {
      addPlayer();
    }
    if (isMounted &&
        enemiesFullyAdded &&
        world.children.whereType<Enemy>().isEmpty &&
        world.children.whereType<TextComponent>().isEmpty) {
      world.addAll(
        [
          (position: Vector2(0.5, 0.5), color: Colors.white),
          (position: Vector2.zero(), color: Colors.orangeAccent),
        ].map(
          (e) => TextComponent(
            text: 'You win!',
            anchor: Anchor.center,
            position: e.position,
            textRenderer: TextPaint(
              style: TextStyle(color: e.color, fontSize: 16),
            ),
          ),
        ),
      );
    }
  }

  var enemiesFullyAdded = false;

  Future<void> addEnemies() async {
    for (var i = 0; i < 2000; i++) {
    await Future<void>.delayed(const Duration(milliseconds:900 ));
      print(EnemyColor.randomColor.fileName);
      await world.add(
        Enemy(
          Vector2(
              camera.visibleWorldRect.right / 3 +
                  (_random.nextDouble() * 7 - 3.5),
                    -25),
          aliens.getSprite(EnemyColor.randomColor.fileName),
          
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    // enemiesFullyAdded = true; 
  }        

}