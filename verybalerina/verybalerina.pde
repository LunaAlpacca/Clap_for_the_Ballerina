
import ddf.minim.*; 

Minim minim; 
AudioInput audioInput; 
float amplitude; 

int numFrames = 6; // Number of unique frames
int currentFrame = 0; // Current frame index
int direction = 1; // Direction of playback: 1 (forward), -1 (backward)
PImage[] images = new PImage[numFrames];
float threshold = 0.01; // Amplitude threshold for triggering animation
boolean soundActive = false; // Tracks if sound is currently triggering animation

void setup() {
  size(1000, 1000); 
  frameRate(12);
  imageMode(CENTER);

  // Initialize Minim and audio input
  minim = new Minim(this);
  audioInput = minim.getLineIn(Minim.MONO, 512);
  println("AudioInput: " + audioInput);

  // Load images
  for (int i = 0; i < numFrames; i++) {
    images[i] = loadImage("balett" + (i + 1) + ".jpg");
    if (images[i] == null) {
      println("Failed to load image at index: " + i);
    }
  }
}

void draw() { 
  background(0); 

  if (audioInput != null && images[currentFrame] != null) {
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
    } else {
      // No sound, recover back to standing position
      soundActive = false;
      if (currentFrame > 0) {
        direction = -1; // Move backward toward frame 1
        currentFrame += direction;
      }
    }

    // Display the current frame
    image(images[currentFrame], width / 2, height / 2);
  } else {
    println("Audio input or image not initialized properly.");
  }
}

void stop() {
  if (audioInput != null) audioInput.close();
  minim.stop();
  super.stop();
}
