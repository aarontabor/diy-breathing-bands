import java.util.LinkedList;


class BreathVisualizer {
	
	protected BreathReader chestReader;
	protected BreathReader abdomenReader;
	private int x;
	private int y;
	protected int w;
	protected int h;

	public BreathVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		this(chestReader, chestReader, x, y, w, h);
	}

	public BreathVisualizer(BreathReader chestReader, BreathReader abdomenReader, int x, int y, int w, int h) {
		this.chestReader = chestReader;
		this.abdomenReader = abdomenReader;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public void update() {}

	public void draw() {
		predraw();
		drawVisualizer();
		postdraw();
	}

	private void predraw() {
		pushMatrix();
		translate(x, y);
		
		stroke(0);
		fill(0);

		rectMode(CENTER);
		ellipseMode(CENTER);
	}

	// extend this method in subclasses
	protected void drawVisualizer() {}

	private void postdraw() {
		popMatrix();
	}
}


class WaveVisualizer extends BreathVisualizer {

	private LinkedList<Float> readings;

	public WaveVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
		readings = new LinkedList<Float>();
	}

	public void update() {
		readings.add(chestReader.read());
		if (readings.size() > 2*w) {
			readings.remove();
		}
	}
	
	public void drawVisualizer() {
		fill(0, 0, 0, 0);
		rect(0, 0, w, h);

		float dotX = -w/2;
		for (float r : readings) {
			int dotY = int(map(r, 0.0, 1.0, h/2, -h/2));
			point(dotX, dotY);
			dotX += 0.5;
		}
	}
}


class BarVisualizer extends BreathVisualizer {

	public BarVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float barY = map(chestReader.read(), 0.0, 1.0, h/2, -h/2);
		rect(0, barY, w, h/10);
	}
}


class AlphaVisualizer extends BreathVisualizer {

	public AlphaVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float transparancy = map(chestReader.read(), 0.0, 1.0, 0, 255);
		fill(0, 0, 0, transparancy);
		ellipse(0, 0, w, h);
	}
}


class TwoColorVisualizer extends BreathVisualizer {

	public TwoColorVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float transparancy = map(chestReader.read(), 0.0, 1.0, 0, 255);
		color c = color(0, 0, 0);

		BreathState state = chestReader.readState();
		if (state == BreathState.INHALE || state == BreathState.HOLD_FULL) {
			c = color(0, 0, 255);
		} else if (state == BreathState.EXHALE || state == BreathState.HOLD_EMPTY) {
			c = color(255, 0, 0);
		}
		
		fill(c, transparancy);
		ellipse(0, 0, w, h);
	}
}


class FillVisualizer extends BreathVisualizer {

	public FillVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float reading = chestReader.read();
		float angle = map(reading, 0.0, 1.0, 0.0, PI);
		arc(0, 0, w, h, HALF_PI-angle, HALF_PI+angle, OPEN);
	}
}


class ClockVisualizer extends BreathVisualizer {

	public ClockVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float angle = map(chestReader.read(), 0.0, 1.0, -HALF_PI, TWO_PI-HALF_PI);
		arc(0, 0, w, h, -HALF_PI, angle);
	}
}


class GrowVisualizer extends BreathVisualizer {

	public GrowVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float radius = map(chestReader.read(), 0.0, 1.0, 0.5*w, w);
		ellipse(0, 0, radius, radius);
	}
}


class GrowFillVisualizer extends BreathVisualizer {

	public GrowFillVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float radius = map(chestReader.read(), 0.0, 1.0, 0.5*w, w);
		float angle = map(chestReader.read(), 0.0, 1.0, 0.0, PI);
		arc(0, 0, radius, radius, HALF_PI-angle, HALF_PI+angle, OPEN);
		fill(0,0,0,0);
		ellipse(0, 0, radius, radius);
	}
}


class GrowAlphaVisualizer extends BreathVisualizer {

	public GrowAlphaVisualizer(BreathReader chestReader, int x, int y, int w, int h) {
		super(chestReader, x, y, w, h);
	}

	public void drawVisualizer() {
		float radius = map(chestReader.read(), 0.0, 1.0, 0.5*w, w);
		float transparancy = map(chestReader.read(), 0.0, 1.0, 0, 255);
		fill(0,0,0,transparancy);
		ellipse(0, 0, radius, radius);
	}
}

