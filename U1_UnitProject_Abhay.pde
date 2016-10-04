import damkjer.ocd.*;
import processing.net.*;

boolean upPressed, downPressed, leftPressed, rightPressed;
float movementSpeed = 20;

Camera cam;

float range = 10000;

PVector paddle;
float paddleSize = 50;

float[] target;
float[] camPos;

ArrayList<Bullet> b = new ArrayList<Bullet>();
ArrayList<MovingEnemy> mE = new ArrayList<MovingEnemy>();
ArrayList<ShootingEnemy> sE = new ArrayList<ShootingEnemy>();

PVector bulletTarget;
PVector bulletSpawn;

PVector spawn;

String input;

Player player;

float health = 100;
float score = 0;

void setup()
{
  fullScreen(P3D);
  noStroke();
  rectMode(CENTER);

  noCursor();

  PVector playerSpawn = new PVector(0, height/2, 0);

  player = new Player(playerSpawn);

  cam = new Camera(this, player.pos.x, player.pos.y, player.pos.z, player.pos.x, player.pos.y, -range);
  
  textAlign(CENTER);
}

void draw()
{
  background(0);

  target = cam.target();
  camPos = cam.position();

  cam.feed();
  mouseLook();

  bulletSpawn = new PVector(camPos[0], camPos[1], camPos[2]);

  player.pos.x = camPos[0];
  player.pos.y = camPos[1];
  player.pos.z = camPos[2];

  bulletTarget = new PVector(target[0], target[1], target[2]);

  if (mE.size() < 5)
  {
    int spawnPlace = (int) random(3);

    switch(spawnPlace)
    {
    case 0:
      spawn = new PVector(random(-width, width), random(height), -range + 100);
      mE.add(new MovingEnemy(spawn, player.pos, random(5, 10), random(50, 200), 0));
      break;

    case 1:
      spawn = new PVector(-width + 100, random(height), random(-range, -range/2));
      mE.add(new MovingEnemy(spawn, player.pos, random(5, 10), random(50, 200), 0));
      break;

    case 2:
      spawn = new PVector(width - 100, random(height), random(-range, -range/2));
      mE.add(new MovingEnemy(spawn, player.pos, random(5, 10), random(50, 200), 0));
      break;
    }
  }

  if (sE.size() < 2)
  {
    int spawnPlace = (int) random(3);

    switch(spawnPlace)
    {
    case 0:
      spawn = new PVector(random(-width, width), random(height), -range + 100);
      sE.add(new ShootingEnemy(spawn, random(50, 200), 0, random(4000, 8000)));
      break;

    case 1:
      spawn = new PVector(-width, random(height), random(-range, 0));
      sE.add(new ShootingEnemy(spawn, random(50, 200), 0, random(4000, 8000)));
      break;

    case 2:
      spawn = new PVector(width, random(height), random(-range, 0));
      sE.add(new ShootingEnemy(spawn, random(50, 200), 0, random(4000, 8000)));
      break;
    }
  }

  pushMatrix();
  translate(0, height/2, -range/2);
  noFill();
  stroke(255);
  box(width*2, height, range);
  popMatrix();

  for (int i = 0; i < b.size(); i++)
  {
    b.get(i).update(); 

    if (b.get(i).pos.x < -width || b.get(i).pos.x > width || b.get(i).pos.y < 0 || b.get(i).pos.y > height || b.get(i).pos.z < -range || b.get(i).pos.z > 0)
    {
      b.remove(i);
    }
  }

  for (int i = 0; i < mE.size(); i++)
  {
    mE.get(i).update();
    mE.get(i).checkCollision();

    if (mE.get(i).killed)
    {
      mE.remove(i);
      score += 6;
      health++;
    }
  }

  for (int i = 0; i < sE.size(); i++)
  {
    sE.get(i).update(); 
    sE.get(i).shoot(sE.get(i).pos, player.pos);

    if (sE.get(i).killed)
    {
      sE.remove(i);
      score += 8;
      health++;
    }
  }

  noStroke();
  fill(255, 0, 0);
  pushMatrix();
  translate(target[0], target[1], target[2]);
  sphere(30);
  strokeWeight(5);
  stroke(0, 255, 0);
  noFill();
  arc(0, 0, 300, 300, 0, radians(health*3.6));
  fill(255);
  textSize(200);
  text((int) score, - width/2 + 200, - height/2 + 100);
  popMatrix();

  strokeWeight(1);
  noStroke();
  fill(255);
  
  health += 0.025;
}

void mousePressed()
{
  b.add(new Bullet(player.pos, bulletTarget, 100));
  score -= 3;
}