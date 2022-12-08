// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module win

import ui
import model

struct ToolClear {
    pub:
    name string
    title string
    mut:
    model &model.Model
}

fn new_clear_tool( mut model &model.Model ) &ToolClear {
    return &ToolClear{
        name: "clear"
        title: "Clear"
        model: model
    }
}

fn (mut t ToolClear) active( mut mw MainWindow ) {
    mw.win.message( "Are you sure?" )
    mw.select_last_tool()

    t.clear()
}

fn (mut t ToolClear) inactive( mut mw MainWindow ) {}

fn (mut t ToolClear) draw( d ui.DrawDevice, c ui.CanvasLayout, x f64, y f64 ) {}

fn (mut t ToolClear) move( x f64, y f64 ) {}

fn (mut t ToolClear) down( x f64, y f64 ) {}

fn (mut t ToolClear) up( x f64, y f64 ) {}

fn (mut t ToolClear) menu( x f64, y f64 ) {}

fn (mut t ToolClear) clear() {
    t.model.reset()
}
