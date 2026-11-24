#!/usr/bin/env python3
"""Aplica las reglas por aplicación de ~/.config/keyd/app.conf según la ventana activa.

Sustituye a keyd-application-mapper en X11: aquel toma como "activa" cualquier
ventana con _NET_WM_STATE_ABOVE (p. ej. polybar), así que nunca aplicaba las
reglas. Este lee _NET_ACTIVE_WINDOW, que mantiene el gestor de ventanas.

Mismo formato de config que keyd-application-mapper:
    [clase]            o   [clase|título]     (comodines estilo shell)
    capa.tecla = acción
La clase se normaliza igual: minúsculas y no alfanuméricos -> '-'.
"""
import os, re, subprocess, sys, time
from fnmatch import fnmatch

import Xlib.display, Xlib.error, Xlib.X

CONFIG = os.path.expanduser("~/.config/keyd/app.conf")


def log(msg):
    print(msg, flush=True)


def norm_class(s):
    return re.sub(r"[^A-Za-z0-9]+", "-", s).strip("-").lower()


def norm_title(s):
    return re.sub(r"[\W_]+", "-", s).strip("-").lower()


def parse_config(path):
    rules, binds = [], None
    try:
        lines = open(path).read().splitlines()
    except OSError as e:
        log(f"sin config: {e}")
        return rules
    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            cls, _, title = line[1:-1].partition("|")
            binds = []
            rules.append((cls, title or "*", binds))
        elif binds is not None:
            binds.append(line)
    return rules


class Mapper:
    def __init__(self):
        self.dpy = Xlib.display.Display()
        self.root = self.dpy.screen().root
        self.NET_ACTIVE = self.dpy.intern_atom("_NET_ACTIVE_WINDOW")
        self.NET_WM_NAME = self.dpy.intern_atom("_NET_WM_NAME")
        self.root.change_attributes(event_mask=Xlib.X.PropertyChangeMask)
        self.mtime, self.rules, self.applied = None, [], None

    def reload_if_changed(self):
        try:
            m = os.path.getmtime(CONFIG)
        except OSError:
            m = None
        if m != self.mtime:
            self.mtime, self.rules = m, parse_config(CONFIG)
            self.applied = None          # forzar reaplicar
            log(f"config cargada: {len(self.rules)} reglas")

    def active_window(self):
        prop = self.root.get_full_property(self.NET_ACTIVE, Xlib.X.AnyPropertyType)
        if not prop or not prop.value or not prop.value[0]:
            return None
        return self.dpy.create_resource_object("window", prop.value[0])

    def window_info(self, win):
        cls = win.get_wm_class()
        title = ""
        try:
            p = win.get_full_property(self.NET_WM_NAME, Xlib.X.AnyPropertyType)
            title = p.value.decode("utf8", "replace") if p else (win.get_wm_name() or "")
        except Exception:
            pass
        return norm_class(cls[1] if cls else "root"), norm_title(title)

    def update(self):
        self.reload_if_changed()
        try:
            win = self.active_window()
            cls, title = self.window_info(win) if win else ("root", "")
        except Xlib.error.XError:
            return                       # ventana cerrada entre medias
        binds = [b for c, t, bs in self.rules
                 if fnmatch(cls, c) and fnmatch(title, t) for b in bs]
        if binds != self.applied:
            r = subprocess.run(["keyd", "bind", "reset", *binds],
                               capture_output=True, text=True)
            if r.returncode != 0:
                log(f"keyd bind falló ({cls}): {r.stderr.strip() or r.stdout.strip()}")
                return
            self.applied = binds
            log(f"activa: {cls} -> {len(binds)} reglas")

    def run(self):
        self.update()
        while True:
            ev = self.dpy.next_event()
            if ev.type == Xlib.X.PropertyNotify and ev.atom == self.NET_ACTIVE:
                self.update()


def main():
    while True:
        try:
            Mapper().run()
        except Exception as e:           # X caído / keyd reiniciado: reintentar
            log(f"error: {e!r}; reintentando en 3 s")
            time.sleep(3)


if __name__ == "__main__":
    main()
