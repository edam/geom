// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module win

import ui

interface Tool {
    name string
    title string
    mut:
    active( mut MainWindow )
    inactive( mut MainWindow )
    draw( ui.DrawDevice, ui.CanvasLayout, f64, f64 )
    move( f64, f64 )
    down( f64, f64 )
    up( f64, f64 )
    menu( f64, f64 )
}

struct Dragging {
    mut:
    on bool
    dx f64
    dy f64
    dirty bool
}
