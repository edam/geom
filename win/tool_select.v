// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module win

import ui
import model

struct ToolSelect {
    pub:
    name string
    title string
    mut:
    model &model.Model
    hover &model.Geom = model.None{}
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
    //if t.dragging {
    //    if mut t.model.highlighted is model.Point {
    //        t.model.highlighted.move( x, y )
    //    }
    //}
    //else {
    //    t.model.highlight(
    //        t.model.test( x, y, fn( g model.Geom ) bool {
    //            return g !is model.None
    //        } )
    //    )
    //}
}

fn (mut t ToolSelect) down( x f64, y f64 ) {
    //if t.model.highlighted !is model.None {
    //    t.model.set_selected( t.model.highlighted )
    //    t.dragging = true
    //}
}

fn (mut t ToolSelect) up( x f64, y f64 ) {
    //if t.dragging {
    //    t.dragging = false
    //}
}

fn (mut t ToolSelect) menu( x f64, y f64 ) {
}
