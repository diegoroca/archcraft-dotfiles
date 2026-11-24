#!/usr/bin/env python3
"""Abre Steam al pulsar el botón Guide/Xbox de cualquier mando (BTN_MODE).

Feedback al pulsar:
  - vibración corta en el mando que pulsó el botón
  - notificación "Abriendo Steam…" que se cierra sola cuando aparece la ventana

Sin dependencias Python: lee /dev/input/event* directamente y no bloquea el mando.
"""
import fcntl, glob, os, select, struct, subprocess, threading, time

EV_KEY, EV_FF, BTN_MODE, FF_RUMBLE = 0x01, 0x15, 0x13C, 0x50
EVENT = struct.Struct("llHHi")          # struct input_event (64-bit)
# struct ff_effect (48 bytes): type, id, direction, trigger{button,interval},
# replay{length,delay}, padding, union{rumble{strong,weak}, ...}
FF_EFFECT = struct.Struct("=HhHHHHH2xHH28x")
EVIOCSFF = (1 << 30) | (FF_EFFECT.size << 16) | (ord("E") << 8) | 0x80

COOLDOWN = 10                           # s, evita lanzar Steam dos veces
RUMBLE_MS, RUMBLE_STRONG, RUMBLE_WEAK = 150, 0x6000, 0x9000
WINDOW_TIMEOUT = 120                    # s, máximo que espera la ventana
PATH = "/usr/local/bin:/usr/bin:/bin:" + os.path.expanduser("~/.local/bin")


def log(msg):
    print(msg, flush=True)


# ---------------------------------------------------------------- dispositivos
def caps(ev, kind):
    """Bitmask de capacidades del dispositivo leída de sysfs (key, ff...)."""
    try:
        with open(f"/sys/class/input/{ev}/device/capabilities/{kind}") as f:
            words = f.read().split()
    except OSError:
        return 0
    return int("".join(w.zfill(16) for w in words), 16)


def open_pads(pads):
    known = {p["path"] for p in pads.values()}
    for path in glob.glob("/dev/input/event*"):
        ev = os.path.basename(path)
        if path in known or not caps(ev, "key") >> BTN_MODE & 1:
            continue
        try:  # lectura+escritura para poder vibrar; si no, solo lectura
            fd = os.open(path, os.O_RDWR | os.O_NONBLOCK)
        except OSError:
            try:
                fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
            except OSError:
                continue
        rumble = bool(caps(ev, "ff") >> FF_RUMBLE & 1)
        pads[fd] = {"path": path, "rumble": rumble, "effect": None}
        log(f"escuchando {path}" + (" (vibración)" if rumble else ""))


def rumble(fd, pad):
    if not pad["rumble"]:
        return
    try:
        if pad["effect"] is None:       # subir el efecto una vez por dispositivo
            buf = bytearray(FF_EFFECT.pack(FF_RUMBLE, -1, 0, 0, 0, RUMBLE_MS, 0,
                                           RUMBLE_STRONG, RUMBLE_WEAK))
            fcntl.ioctl(fd, EVIOCSFF, buf, True)
            pad["effect"] = struct.unpack_from("=h", buf, 2)[0]
        os.write(fd, EVENT.pack(0, 0, EV_FF, pad["effect"], 1))
    except OSError as e:
        log(f"sin vibración en {pad['path']}: {e}")
        pad["rumble"] = False


# ---------------------------------------------------------------- steam
def session_env():
    """Entorno gráfico actual (XAUTHORITY cambia en cada sesión)."""
    env = dict(os.environ)
    out = subprocess.run(["/usr/bin/systemctl", "--user", "show-environment"],
                         capture_output=True, text=True).stdout
    for line in out.splitlines():
        k, _, v = line.partition("=")
        if k in ("DISPLAY", "XAUTHORITY", "DBUS_SESSION_BUS_ADDRESS",
                 "WAYLAND_DISPLAY", "XDG_RUNTIME_DIR"):
            env[k] = v
    env["PATH"] = PATH                  # el PATH del gestor de usuario viene recortado
    return env


def steam_running():
    for comm in glob.glob("/proc/[0-9]*/comm"):
        try:
            with open(comm) as f:
                if f.read().strip() == "steam":
                    return True
        except OSError:
            pass
    return False


def steam_window_visible(env):
    r = subprocess.run(["/usr/bin/xdotool", "search", "--onlyvisible", "--class", "steam"],
                       env=env, capture_output=True)
    return r.returncode == 0 and r.stdout.strip() != b""


def notify_until_window(env):
    """Muestra la notificación y la cierra cuando aparece la ventana de Steam."""
    try:
        nid = subprocess.run(
            ["/usr/bin/dunstify", "-p", "-a", "Steam", "-i", "steam", "-u", "low",
             "-t", str(WINDOW_TIMEOUT * 1000), "Abriendo Steam…"],
            env=env, capture_output=True, text=True).stdout.strip()
    except OSError as e:
        log(f"sin notificación: {e}")
        return
    deadline = time.monotonic() + WINDOW_TIMEOUT
    while time.monotonic() < deadline:
        if steam_window_visible(env):
            break
        time.sleep(0.5)
    if nid:
        subprocess.run(["/usr/bin/dunstify", "-C", nid], env=env, capture_output=True)


def launch_steam():
    if steam_running():
        return False                    # ya abierto: Steam gestiona el botón
    log("lanzando steam")
    env = session_env()
    try:
        subprocess.Popen(["/usr/bin/steam"], env=env, start_new_session=True,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except OSError as e:
        log(f"no se pudo lanzar steam: {e}")
        return False
    threading.Thread(target=notify_until_window, args=(env,), daemon=True).start()
    return True


# ---------------------------------------------------------------- bucle
def main():
    pads, last = {}, 0.0
    while True:
        open_pads(pads)
        ready, _, _ = select.select(list(pads), [], [], 2)  # rescan cada 2 s
        for fd in ready:
            try:
                data = os.read(fd, EVENT.size * 64)
            except OSError:             # mando desconectado
                log(f"perdido {pads[fd]['path']}")
                os.close(fd)
                del pads[fd]
                continue
            for i in range(0, len(data) - EVENT.size + 1, EVENT.size):
                _, _, typ, code, val = EVENT.unpack_from(data, i)
                if typ == EV_KEY and code == BTN_MODE and val == 1:
                    if time.monotonic() - last > COOLDOWN and not steam_running():
                        last = time.monotonic()
                        rumble(fd, pads[fd])   # primero: respuesta instantánea
                        launch_steam()


if __name__ == "__main__":
    main()
