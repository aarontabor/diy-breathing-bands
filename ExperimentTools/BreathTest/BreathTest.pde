//
// Breath Test
//
// Testing various visulations for arduino breath sensing bands
//

import controlP5.*;
import java.util.*;

ControlP5 controlP5;
float cpm;
String sensor;



ArrayList<BreathReader> readers;
ArrayList<BreathVisualizer> visualizers;


void setup() {
	size(600, 400);
	background(255);

	buildGuiButtons();

	readers = new ArrayList<BreathReader>();
	readers.add(new BreathReader());

	visualizers = new ArrayList<BreathVisualizer>();
	visualizers.add(new WaveVisualizer(readers.get(0), 350, 40, 400, 60));

	visualizers.add(new BarVisualizer(readers.get(0), 75, 150, 100, 100));
	visualizers.add(new AlphaVisualizer(readers.get(0), 225, 150, 100, 100));
	visualizers.add(new TwoColorVisualizer(readers.get(0), 375, 150, 100, 100));
	visualizers.add(new FillVisualizer(readers.get(0), 525, 150, 100, 100));

	visualizers.add(new ClockVisualizer(readers.get(0), 75, 300, 100, 100));
	visualizers.add(new GrowVisualizer(readers.get(0), 225, 300, 100, 100));
	visualizers.add(new GrowFillVisualizer(readers.get(0), 375, 300, 100, 100));
	visualizers.add(new GrowAlphaVisualizer(readers.get(0), 525, 300, 100, 100));
}

private void buildGuiButtons() {
	controlP5 = new ControlP5(this);
	controlP5.addSlider("cpm")
		.setPosition(20, 20)
		.setSize(75, 15)
		.setRange(4.0, 20.0)
		.setValue(8.0)
		.setColorCaptionLabel(color(0,0,0));
	controlP5.addScrollableList("sensor")
    	.setPosition(20, 50)
    	.setSize(75, 65)
    	.setBarHeight(20)
    	.setItemHeight(15)
    	.addItems(Arrays.asList("Flex", "Stretch Cord", "Stretch Fabric"))
    	.setType(ScrollableList.DROPDOWN); // currently supported DROPDOWN and LIST
}


void draw() {
	clear();
	background(255);

	for (BreathReader r : readers) {
		r.update();
	}
	
	for (BreathVisualizer v : visualizers) {
		v.update();
		v.draw();
	}
}