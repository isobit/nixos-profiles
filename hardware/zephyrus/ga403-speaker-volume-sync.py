#!/usr/bin/env python3
"""ga403-speaker-volume-sync

Mirror the ALSA "Master" volume on the ASUS ROG Zephyrus G14 (GA403UP) onto the
two Cirrus Logic CS35L56 woofer amplifiers ("AMP1 Speaker" / "AMP2 Speaker"),
which otherwise stay pinned near 0 dB while Master is attenuated. This keeps the
woofer/tweeter balance sane at low desktop volume.

Standalone: only `amixer` (reads/writes) and `alsactl monitor` (Master change
events) are spawned, both from alsa-utils; all parsing and math happen
in-process. Runnable directly for testing.

The ALSA card index is auto-detected by finding the card that actually exposes
the CS35L56 "AMP1 Speaker" control, because bare card numbers are not stable
across boots. Set CARD to pin a specific index.

Usage:
  ga403-speaker-volume-sync            # apply once, then follow events + poll
  ga403-speaker-volume-sync --once     # apply a single time and exit
  ga403-speaker-volume-sync --dry-run  # log targets but change nothing
  ga403-speaker-volume-sync --show     # print mixer state and exit

Environment overrides (all optional):
  CARD           ALSA card number         (default: auto-detect, else 3)
  OFFSET_DB      constant dB added to the woofer path (default 0)
  SLOPE          Master dB multiplier                 (default 1.0)
  POLL_INTERVAL  reconcile seconds (0 disables poll)  (default 10)
  EVENT_DEBOUNCE seconds to coalesce change events    (default 0.3)
  ZERO_DB_STEP   raw amp step equal to 0 dB           (default 400)
  MIN_STEP       lowest raw amp step allowed          (default 0)
  MAX_STEP       highest raw amp step allowed          (default 400)

Relationship: woofer_dB = OFFSET_DB + (Master_dB * SLOPE)
"""

import os
import re
import subprocess
import sys
import threading
import time


def _env_float(name, default):
    try:
        return float(os.environ[name])
    except (KeyError, ValueError):
        return default


def _env_int(name, default):
    try:
        return int(os.environ[name])
    except (KeyError, ValueError):
        return default


# Resolved at startup by detect_card(). CARD_DEFAULT is the last-resort index
# used only when auto-detection fails and no explicit CARD override is set.
CARD_DEFAULT = 3
CARD = CARD_DEFAULT
OFFSET_DB = _env_float("OFFSET_DB", 0.0)
SLOPE = _env_float("SLOPE", 1.0)
POLL_INTERVAL = _env_int("POLL_INTERVAL", 10)
EVENT_DEBOUNCE = _env_float("EVENT_DEBOUNCE", 0.3)

# CS35L56 "AMP{1,2} Speaker": raw 400 = 0 dB, ~0.25 dB per raw step. ALSA
# reports a nominal max of 448, but we deliberately cap at 400 (0 dB) so the
# script never drives the amps hotter than their calibrated reference.
ZERO_DB_STEP = _env_int("ZERO_DB_STEP", 400)
MIN_STEP = _env_int("MIN_STEP", 0)
MAX_STEP = _env_int("MAX_STEP", 400)
DB_PER_STEP = 0.25

_DB_RE = re.compile(r"(-?\d+\.\d+)dB")
# Match the channel readout ("Mono: Playback 334 [75%]"), not the
# "Limits: Playback 0 - 448" line, by requiring the trailing " [".
_RAW_RE = re.compile(r"Playback (\d+) \[")

_apply_lock = threading.Lock()


def log(msg):
    print(msg, file=sys.stderr, flush=True)


def amixer(*args):
    """Run amixer; return stdout on success, or None (logged) on failure."""
    proc = subprocess.run(
        ["amixer", "-c", str(CARD), *args],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        out = (proc.stdout + proc.stderr).strip()
        log(f"ERROR: amixer {' '.join(args)} failed (exit {proc.returncode}): {out}")
        return None
    return proc.stdout


def _list_cards():
    """Return ALSA card indices listed in /proc/asound/cards."""
    try:
        with open("/proc/asound/cards") as f:
            text = f.read()
    except OSError as exc:
        log(f"WARNING: could not read /proc/asound/cards: {exc}")
        return []
    return [int(m) for m in re.findall(r"^\s*(\d+)\s+\[", text, re.MULTILINE)]


def _card_has_amps(card):
    """True if the given card exposes the CS35L56 "AMP1 Speaker" control."""
    proc = subprocess.run(
        ["amixer", "-c", str(card), "scontrols"],
        capture_output=True,
        text=True,
    )
    return proc.returncode == 0 and "AMP1 Speaker" in proc.stdout


def detect_card():
    """Resolve the ALSA card index for the CS35L56 amps.

    Honors an explicit CARD override; otherwise finds the card that actually
    exposes the "AMP1 Speaker" control, since bare card numbers are not stable
    across boots. Falls back to CARD_DEFAULT when detection fails.
    """
    env = os.environ.get("CARD")
    if env is not None:
        try:
            return int(env)
        except ValueError:
            log(f"WARNING: ignoring non-integer CARD={env!r}")
    for card in _list_cards():
        if _card_has_amps(card):
            return card
    log(f"WARNING: could not detect CS35L56 card; falling back to {CARD_DEFAULT}")
    return CARD_DEFAULT


def read_master_db():
    out = amixer("sget", "Master")
    if out is None:
        return None
    m = _DB_RE.search(out)
    if not m:
        log("ERROR: could not parse Master dB. Full amixer output:")
        print(out, file=sys.stderr, flush=True)
        return None
    return float(m.group(1))


def read_amp_raw(control):
    out = amixer("sget", control)
    if out is None:
        return None
    m = _RAW_RE.search(out)
    return int(m.group(1)) if m else None


def compute_step(master_db):
    woofer_db = OFFSET_DB + master_db * SLOPE
    raw = round(ZERO_DB_STEP + woofer_db / DB_PER_STEP)
    return max(MIN_STEP, min(MAX_STEP, raw))


def apply(dry_run=False):
    with _apply_lock:
        master_db = read_master_db()
        if master_db is None:
            return False
        step = compute_step(master_db)
        amp1 = read_amp_raw("AMP1 Speaker")
        amp2 = read_amp_raw("AMP2 Speaker")

        log(
            f"apply: Master={master_db}dB target={step} "
            f"(AMP1={amp1 if amp1 is not None else 'unknown'} "
            f"AMP2={amp2 if amp2 is not None else 'unknown'})"
        )

        if dry_run:
            log(f"dry-run: would set AMP1/AMP2 Speaker to {step}")
            return True

        if amp1 == step and amp2 == step:
            return True

        ok = True
        for control in ("AMP1 Speaker", "AMP2 Speaker"):
            if amixer("-q", "sset", control, str(step)) is None:
                log(f"ERROR: failed to set {control} to {step}")
                ok = False
        return ok


def show():
    for control in ("Master", "AMP1 Speaker", "AMP2 Speaker"):
        out = amixer("sget", control)
        if out is not None:
            sys.stdout.write(out)


def poll_loop():
    # The CS35L56 amps can silently reinitialize to default high gain after
    # runtime power events (no PipeWire event fires), so re-assert the target
    # periodically. Steady state skips the writes, so this is cheap.
    while True:
        time.sleep(POLL_INTERVAL)
        if not apply():
            log("WARNING: periodic apply failed")


def event_loop():
    # `alsactl monitor` (alsa-utils) prints one line per ALSA control change on
    # the card, e.g.
    #   node hw:3, #24 (2,0,0,Master Playback Volume,0) VALUE
    # We react only to "Master" changes: this ignores the AMP1/AMP2 events our
    # own writes generate (avoiding a feedback loop) and the PCM control. A
    # short debounce coalesces the burst a single volume change produces.
    log(f"monitoring ALSA controls via alsactl monitor hw:{CARD}")
    proc = subprocess.Popen(
        ["alsactl", "monitor", f"hw:{CARD}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    trigger = threading.Event()

    def reader():
        for line in proc.stdout:
            if "Master" in line:
                trigger.set()

    threading.Thread(target=reader, daemon=True).start()

    while proc.poll() is None:
        if not trigger.wait(timeout=1.0):
            continue
        trigger.clear()
        if not apply():
            log("WARNING: apply failed after Master change")
        time.sleep(EVENT_DEBOUNCE)  # coalesce bursts of change events

    status = proc.wait()
    log(f"ERROR: alsactl monitor exited (status {status}); service will restart")
    return status


def main(argv):
    global CARD
    arg = argv[1] if len(argv) > 1 else ""

    CARD = detect_card()

    if arg == "--show":
        show()
        return 0
    if arg == "--once":
        return 0 if apply() else 1
    dry_run = arg == "--dry-run"
    if arg and not dry_run:
        log(f"ERROR: unknown argument: {arg}")
        return 2

    log(
        f"starting: CARD={CARD} OFFSET_DB={OFFSET_DB} SLOPE={SLOPE} "
        f"POLL_INTERVAL={POLL_INTERVAL} ZERO_DB_STEP={ZERO_DB_STEP} "
        f"MIN_STEP={MIN_STEP} MAX_STEP={MAX_STEP} dry_run={dry_run}"
    )

    if not apply(dry_run=dry_run):
        log("WARNING: initial apply failed; waiting for ALSA events")

    if dry_run:
        log("dry-run: applied once, exiting")
        return 0

    if POLL_INTERVAL > 0:
        threading.Thread(target=poll_loop, daemon=True).start()

    return event_loop()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
