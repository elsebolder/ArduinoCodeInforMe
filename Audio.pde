import processing.sound.*;
SoundFile file1;
SoundFile file2;
SoundFile file3;
SoundFile file4;
SoundFile file5;
SoundFile file6;
SoundFile file7;
SoundFile file8;
SoundFile file9;


int rotaryStep = 1;
int rotaryOld = rotary;
int rotaryNew = rotary;
int rotaryDifference = 0;
long playTime = 0;
long startTime = 0;
long runTime = 0;
int currentAudio = 0;
int previousAudio = 0;
int AudioCheck = 0;
long jumpTime = 0;
boolean timerRunning = false;
int jumpLength = 2;//how far the file needs to jump back in seconds


void cueAudio() {

  if (timerRunning == false && (file1.isPlaying() || file2.isPlaying() || file3.isPlaying() || file4.isPlaying() || file5.isPlaying() || file6.isPlaying() || file7.isPlaying() || file8.isPlaying() || file9.isPlaying())) { // audio file playing & timer not running already
    startTime = millis();//takes the time when program started. this is not updated continuesly as timerRunning becomes true.
    timerRunning = true;
    previousAudio = currentAudio;
  }
  if (timerRunning == true) {
    runTime = millis();// keeps updating the time in millis as long as timerRunning is true
    playTime = runTime - startTime;
    AudioCheck = currentAudio - previousAudio;
  }
  if (AudioCheck != 0) {
    timerRunning = false;
  }
  if (!(file1.isPlaying() || file2.isPlaying() || file3.isPlaying() || file4.isPlaying() || file5.isPlaying() || file6.isPlaying() || file7.isPlaying() || file8.isPlaying() || file9.isPlaying())) {
    currentAudio = 0;
  }

  //println("startTime = " + startTime);
  //println("runtime = " + runTime);
  //println("Playtime = " + playTime);
  if (buttonPressed != 0) {
    println("currentAudio = " + currentAudio);
  }

  if (buttonPressed == 1) {
    stopAudio();
    file1.play(1,0,1,0,0);//.play(rate, pos, amp, add, cue) Always start at the beginning: cue --> 0.
    currentAudio = 1;
    buttonPressed = 0;
  }

  if (buttonPressed == 2) {
    stopAudio();
    file2.play(1,0,1,0,0);
    currentAudio = 2;
    buttonPressed = 0;
  }

  if (buttonPressed == 3) {
    stopAudio();
    file3.play(1,0,1,0,0);
    currentAudio = 3;
    buttonPressed = 0;
  }

  if (buttonPressed == 4) {
    stopAudio();
    file4.play(1,0,1,0,0);
    currentAudio = 4;
    buttonPressed = 0;
  }

  if (buttonPressed == 5) {
    stopAudio();
    file5.play(1,0,1,0,0);
    currentAudio = 5;
    buttonPressed = 0;
  }

  if (buttonPressed == 6) {
    stopAudio();
    file6.play(1,0,1,0,0);
    currentAudio = 6;
    buttonPressed = 0;
  }

  if (buttonPressed == 7) {
    stopAudio();
    file7.play(1,0,1,0,0);
    currentAudio = 7;
    buttonPressed = 0;
  }

  if (buttonPressed == 8) {
    stopAudio();
    file8.play(1,0,1,0,0);
    currentAudio = 8;
    buttonPressed = 0;
  }

  if (buttonPressed == 9) {
    stopAudio();
    file9.play(1,0,1,0,0);
    currentAudio = 9;
    buttonPressed = 0;
  }
}

void stopAudio() {
  file1.stop();
  file2.stop();
  file3.stop();
  file4.stop();
  file5.stop();
  file6.stop();
  file7.stop();
  file8.stop();
  file9.stop();
}

//void scrollAudio() {
//  rotaryNew = rotary;
//  if ((rotaryNew - rotaryOld >= rotaryStep) && file2.isPlaying() && playTime > 5000) {
//    jumpTime = (playTime/1000) - jumpLength;//Jumptime works in seconds
//    startTime = startTime + jumpLength*1000;// moving the start Time 5 seconds forward so the gap becomes smaller.
//    file2.jump(jumpTime);
//    rotaryOld = rotaryNew;
//  }
//  println("potNew = " + rotaryNew);
//  println("potOld = " + rotaryOld);
//}

void scrollAudio2() {
  rotaryNew = rotary;
  rotaryDifference = abs (rotaryNew - rotaryOld);

  if ((rotaryDifference >= rotaryStep) && file1.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file1.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file2.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file2.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file3.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file3.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file4.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file4.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file5.isPlaying() && playTime > (jumpLength * 1000)) {
    println("This adio is cued........................................................................................................................................................................");
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file5.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file6.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file6.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file7.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file7.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file8.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file8.jump(jumpTime);
    rotaryOld = rotaryNew;
  }

  if ((rotaryDifference >= rotaryStep) && file9.isPlaying() && playTime > (jumpLength * 1000)) {
    jumpTime = (playTime/1000) - (jumpLength * rotaryDifference);//Jumptime works in seconds
    startTime = startTime + (jumpLength * 1000);// moving the start Time 5 seconds forward so the gap becomes smaller.
    file9.jump(jumpTime);
    rotaryOld = rotaryNew;
  }


  //println("potNew = " + rotaryNew);
  //println("potOld = " + rotaryOld);

}
