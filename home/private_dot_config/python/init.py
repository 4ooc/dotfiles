import atexit
import sys
import os
import readline


def register_readline():
    readline_doc = getattr(readline, "__doc__", "")
    if readline_doc is not None and "libedit" in readline_doc:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

    try:
        readline.read_init_file()
    except OSError:
        pass

    if readline.get_current_history_length() == 0:
        if "PYTHONHISTFILE" in os.environ:
            history = os.environ["PYTHONHISTFILE"]
        else:
            history = os.environ["HOME"] + "/.cache/python/python_history"

        history = os.path.abspath(history)
        _dir, _ = os.path.split(history)
        os.makedirs(_dir, exist_ok=True)
        try:
            readline.read_history_file(history)
        except OSError:
            pass

        def write_history():
            try:
                readline.write_history_file(history)
            except OSError:
                pass

        atexit.register(write_history)


sys.__interactivehook__ = register_readline
