class BreathReader {

	private float previousReading;
	private float currentReading;
	private BreathState previousState;
	private BreathState currentState;


	public BreathReader() {
		previousReading = 0;
		currentReading = 0;
		previousState = BreathState.INHALE;
		currentState = BreathState.INHALE;
	}

	public void update() {
		int modulus = int((60/cpm) * 1000);
		float tmpReading = sin(map(millis() % modulus, 0, modulus, 0, TWO_PI));
		previousReading = currentReading;
		currentReading = tmpReading;

		// TODO: this won't work with a real signal
		BreathState tmpState = null;
		float statePredictor = tmpReading - previousReading;
		if (statePredictor > 0) {
			tmpState = BreathState.INHALE;
		} else if (statePredictor < 0) {
			tmpState = BreathState.EXHALE;
		} else if (statePredictor == 0 && (previousState == BreathState.EXHALE || previousState == BreathState.HOLD_EMPTY)) {
			tmpState = BreathState.HOLD_EMPTY;
		} else if (statePredictor == 0 && (previousState == BreathState.INHALE || previousState == BreathState.HOLD_FULL)) {
			tmpState = BreathState.HOLD_FULL;
		}
		previousState = currentState;
		currentState = tmpState;

	}

	public float readRaw() {
		return currentReading;
	}

	public float readScaled() {
		// TODO: what about the different raw ranges from different sensors?
		return map(readRaw(), -1.0, 1.0, 0.0, 1.0);
	}

	public float read() {
		// TODO: smooth signal somehow
		return readScaled();

	}

	public BreathState readState() {
		return currentState;
	}
}


public enum BreathState { INHALE, HOLD_FULL, EXHALE, HOLD_EMPTY };