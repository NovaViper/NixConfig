{
  config,
  lib,
  myLib,
  ...
}:
myLib.utilMods.mkModule config "btop" {
  # Fancy resource monitor for CLI, replaces top
  hm.programs.btop.enable = true;

  hm.programs.btop.settings = {
    #* Set to True to enable "h,j,k,l,g,G" keys for directional control in lists.
    #* Conflicting keys for h:"help" and k:"kill" is accessible while holding shift.
    vim_keys = true;

    #* Rounded corners on boxes, is ignored if TTY mode is ON.
    rounded_corners = true;

    #* Default symbols to use for graph creation, "braille", "block" or "tty".
    #* "braille" offers the highest resolution but might not be included in all fonts.
    #* "block" has half the resolution of braille but uses more common characters.
    #* "tty" uses only 3 different symbols but will work with most fonts and should work in a real TTY.
    #* Note that "tty" only has half the horizontal resolution of the other two, so will show a shorter historical view.
    graph_symbol = "block";

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_cpu = "default";

    # Graph symbol to use for graphs in gpu box, "default", "braille", "block" or "tty".
    graph_symbol_gpu = "default";

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_mem = "default";

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_net = "default";

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_proc = "default";

    #* Update time in milliseconds, recommended 2000 ms or above for better sample times for graphs.
    update_ms = 1000;

    #* Processes sorting, "pid" "program" "arguments" "threads" "user" "memory" "cpu lazy" "cpu direct",
    #* "cpu lazy" sorts top process over time (easier to follow), "cpu direct" updates top process directly.
    proc_sorting = "cpu lazy";

    #* Reverse sorting order, True or False.
    proc_reversed = false;

    #* Show processes as a tree.
    proc_tree = true;

    #* Use the cpu graph colors in the process list.
    proc_colors = true;

    #* Use a darkening gradient in the process list.
    proc_gradient = true;

    #* In tree-view, always accumulate child process resources in the parent process.
    proc_aggregate = true;
  };
}
