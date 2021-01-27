//
// Breath Logger: Experimental Software for HCI 6065: Course Project
//
// A  GUI tool for logging breath data acquired from DIY monitoring bands.
//
// **** Before using this software, remember to FIRST upload the StandardFirmata program to the arduino board (File >> examples >> Firmata >> StandardFirmata). ****
//

import java.util.*;
import cc.arduino.*;
import processing.serial.*;


HashMap<String, Integer> inputPins;

final color red = color(231, 76, 60);
final color green = color(46, 204, 113);
final color white = color(245);
final color black = color(0);

final String participant = "6";
final String group = "3"; // which order are bands worn in - top to bottom


Table breathTable;
Arduino arduino;
boolean currentlyRecording;


void setup() {
	size(300, 160);
	background(white);

	initializeInputPins();
	initializeBreathTable();
	initializeArduino();
	initializeRecordButton();
}

private void initializeInputPins() {
	inputPins = new HashMap<String, Integer>();
	inputPins.put("flex_chest", 0);
	inputPins.put("flex_abdomen", 1);
	inputPins.put("cord_chest", 2);
	inputPins.put("cord_abdomen", 3);
	inputPins.put("fabric_chest", 4);
	inputPins.put("fabric_abdomen", 5);
}

private void initializeBreathTable() {
	breathTable = new Table();
	breathTable.addColumn("trial");
	breathTable.addColumn("tod");
	breathTable.addColumn("participant");
	breathTable.addColumn("group");
	breathTable.addColumn("flex_chest");
	breathTable.addColumn("flex_abdomen");
	breathTable.addColumn("cord_chest");
	breathTable.addColumn("cord_abdomen");
	breathTable.addColumn("fabric_chest");
	breathTable.addColumn("fabric_abdomen");
}

private void initializeArduino() {
	arduino = new Arduino(this, Arduino.list()[1], 57600);
}

private void initializeRecordButton() {
	currentlyRecording = false;
}


void draw() {
	clear();
	background(white);

	if (currentlyRecording) {
		logBreathRow();
	}

	drawInfoMessages();
	drawArduinoConnectionStatus();
	drawRecordButton();
}

private void drawInfoMessages() {
	textAlign(CENTER);
	textSize(12);
	fill(black);
	String message = "Participant: " + participant + "     Group: " + group;
	text(message, 0.5*width, 20);

	strokeWeight(2);
	stroke(black);
	line(0.05*width, 30, 0.95*width, 30);

}

private void drawArduinoConnectionStatus() {
	pushMatrix();
	translate(40, 65);

	textAlign(RIGHT, CENTER);
	textSize(10);
	fill(black);
	text("Flex", 0, 15);
	text("Cord", 0, 35);
	text("Fabric", 0, 55);

	textAlign(CENTER, BOTTOM);
	text("Chest", 25, 0);
	text("Abdomen", 70, 0);

	ellipseMode(CENTER);
	strokeWeight(0);

	fill(arduino.analogRead(inputPins.get("flex_chest")) > 1000 ? red : green);
	ellipse(25, 15, 10, 10);
	fill(arduino.analogRead(inputPins.get("flex_abdomen")) > 1000 ? red : green);
	ellipse(70, 15, 10, 10);
	fill(arduino.analogRead(inputPins.get("cord_chest")) > 1000 ? red : green);
	ellipse(25, 35, 10, 10);
	fill(arduino.analogRead(inputPins.get("cord_abdomen")) > 1000 ? red : green);
	ellipse(70, 35, 10, 10);
	fill(arduino.analogRead(inputPins.get("fabric_chest")) > 1000 ? red : green);
	ellipse(25, 55, 10, 10);
	fill(arduino.analogRead(inputPins.get("fabric_abdomen")) > 1000 ? red : green);
	ellipse(70, 55, 10, 10);

	popMatrix();
}

private void drawRecordButton() {
	pushMatrix();
	translate(220, 90);

	ellipseMode(CENTER);
	rectMode(CENTER);
	textAlign(CENTER, TOP);
	textSize(12);

	strokeWeight(2);
	stroke(black);
	fill(white);
	rect(0, 0, 100, 100, 5);

	if (!currentlyRecording) {
		strokeWeight(1);
		stroke(red);
		fill(red);
		ellipse(0, 0, 60, 60);

		stroke(white);
		fill(white);
		ellipse(0, 0, 28, 28);

		stroke(black);
		fill(black);
		ellipse(30, -30, 8, 8);

		fill(black);
		text("Record", 0, 35);
	} else {
		strokeWeight(1);
		stroke(red);
		fill(red);
		ellipse(0, 0, 60, 60);

		stroke(white);
		fill(white);
		rect(0, 0, 25, 25, 3);

		stroke(black);
		fill(millis()/1000 % 2 == 0 ? red : black);
		ellipse(30, -30, 8, 8);

		fill(black);
		text("Stop", 0, 35);
	}

	popMatrix();
}


void mouseClicked() {
	if (withinRecordButton()) {
		currentlyRecording = !currentlyRecording;
		if (!currentlyRecording) {
			flushBreathTable();
		}
	}
}

private boolean withinRecordButton() {
	return mouseX >= 220 - 30 && mouseX <= 220 + 30 && mouseY >= 90 - 30 && mouseY <= 90 + 30;
}


private void logBreathRow() {
	TableRow breathRow = breathTable.addRow();
	breathRow.setLong("trial", breathTable.getRowCount());
	breathRow.setLong("tod", System.currentTimeMillis());
	breathRow.setString("participant", participant);
	breathRow.setString("group", group);
	breathRow.setInt("flex_chest", arduino.analogRead(inputPins.get("flex_chest")));
	breathRow.setInt("flex_abdomen", arduino.analogRead(inputPins.get("flex_abdomen")));
	breathRow.setInt("cord_chest", arduino.analogRead(inputPins.get("cord_chest")));
	breathRow.setInt("cord_abdomen", arduino.analogRead(inputPins.get("cord_abdomen")));
	breathRow.setInt("fabric_chest", arduino.analogRead(inputPins.get("fabric_chest")));
	breathRow.setInt("fabric_abdomen", arduino.analogRead(inputPins.get("fabric_abdomen")));
}

private void flushBreathTable() {
	String filename = "p" + participant + "_" + System.currentTimeMillis() + ".csv";
	saveTable(breathTable, filename);
	initializeBreathTable();
}
