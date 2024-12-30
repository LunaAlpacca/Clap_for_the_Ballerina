import ddf.minim.*; 

Minim minim; 
AudioInput audioInput; 
float amplitude; 

int numFrames = 7; // Number of unique frames for the bow animation
int currentFrame = 0; // Current frame index
int direction = 1; // Direction of playback: 1 (forward), -1 (backward)
PImage[] images = new PImage[numFrames];
float threshold = 0.001; // Amplitude threshold for triggering animation
boolean soundActive = false; // Tracks if sound is currently triggering animation

// Variables for idle animation
PImage idleFrame1, idleFrame2;
boolean showingIdleFrame1 = true;
int lastIdleSwitchTime = 0; // Tracks time for switching idle frames
int idleSwitchInterval = 500; // Interval for switching idle frames (1 second)

void setup() {
  size(890, 1408); 
  surface.setResizable(true);
  frameRate(12);
  imageMode(CENTER);

  // Initialize Minim and audio input
  minim = new Minim(this);
  audioInput = minim.getLineIn(Minim.MONO, 512);
  println("AudioInput: " + audioInput);

  // Load animation frames
  for (int i = 0; i < numFrames; i++) {
    images[i] = loadImage("balett" + (i + 1) + ".jpg");
    if (images[i] == null) {
      println("Failed to load image at index: " + i);
    }
  }

  // Load idle animation frames
  idleFrame1 = loadImage("balett1.jpg");
  idleFrame2 = loadImage("balett2.jpg");

  if (idleFrame1 == null || idleFrame2 == null) {
    println("Failed to load idle frames.");
  }
}

void draw() { 
  background(0); 

  if (audioInput != null) {
    amplitude = audioInput.mix.level();

    if (amplitude > threshold) {
      // Sound detected, move forward through animation
      soundActive = true;
      direction = 1; // Ensure animation moves forward
      currentFrame += direction;

      // Stay at the final frame if it exceeds the range
      if (currentFrame >= numFrames - 1) {
        currentFrame = numFrames - 1; // Hold at the bowing position
      }
    } else if (currentFrame > 0) {
      // No sound, recover back to standing position
      soundActive = false;
      direction = -1; // Move backward toward frame 0
      currentFrame += direction;
    } else {
      // No sound and at idle position: play idle animation
      soundActive = false;
      playIdleAnimation();
      return; // Exit early to avoid drawing bow animation
    }

    // Display the current frame of the bow animation
    image(images[currentFrame], width / 2, height / 2);
  } else {
    println("Audio input or image not initialized properly.");
  }
}

void playIdleAnimation() {
  // Switch between idle frames based on the timer
  if (millis() - lastIdleSwitchTime >= idleSwitchInterval) {
    showingIdleFrame1 = !showingIdleFrame1;
    lastIdleSwitchTime = millis();
  }

  // Display the current idle frame
  if (showingIdleFrame1) {
    image(idleFrame1, width / 2, height / 2);
  } else {
    image(idleFrame2, width / 2, height / 2);
  }
}

void stop() {
  if (audioInput != null) audioInput.close();
  minim.stop();
  super.stop();
}
