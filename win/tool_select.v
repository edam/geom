// tool_select.v
//
// Copyright (C) 2022 Tim Marston <tim@edm.am>
//
// This file is part of Geom (hereafter referred to as "this program").
// See http://github.com/edam/geom for more information.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

module win

import ui
import model

struct ToolSelect {
    pub:
    name string
    title string
    mut:
    model &model.Model
    dragging bool
}

fn new_select_tool( mut model &model.Model ) &ToolSelect {
    return &ToolSelect{
        name: "select"
        title: "Select"
        model: model
    }
}

fn (mut t ToolSelect) reset() {}

fn (mut t ToolSelect) draw( d ui.DrawDevice, c ui.CanvasLayout, x f64, y f64 ) {
    /*mut accept_fn := model.AcceptFn( 0 )*/
    /*if mut t.selected is model.Drawable {*/
    /*    selected := t.selected*/
    /*    accept_fn = fn[ selected ]( d model.Drawable ) bool {*/
    /*        return d == selected*/
    /*    }*/
    /*}*/
    /*mut hover := t.mw.model.test( x, y, accept_fn )*/
    /*if mut hover is model.Drawable {*/
    /*    t.mw.model.highlight( hover )*/
    /*}*/
}

fn (mut t ToolSelect) move( x f64, y f64  ) {
    if t.dragging {
        if mut t.model.highlighted is model.Point {
            t.model.highlighted.move( x, y )
        }
    }
    else {
        t.model.highlight(
            t.model.test( x, y, fn( g model.Geom ) bool {
                return g !is model.None
            } )
        )
    }
}

fn (mut t ToolSelect) down( x f64, y f64 ) {
    if t.model.highlighted !is model.None {
        t.model.set_selected( t.model.highlighted )
        t.dragging = true
    }
}

fn (mut t ToolSelect) up( x f64, y f64 ) {
    if t.dragging {
        t.dragging = false
    }
}

fn (mut t ToolSelect) menu( x f64, y f64 ) {
}
