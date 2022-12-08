// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module win

import ui
import model

struct ToolPoint {
    pub:
    name string
    title string
    mut:
    model &model.Model
    hover model.Geom = model.None{}
    dragging Dragging
}

fn new_point_tool( mut model &model.Model ) &ToolPoint {
    return &ToolPoint{
        name: "point"
        title: "Point"
        model: model
    }
}

fn (mut t ToolPoint) reset() {
    t.hover = &model.None{}
}

fn (mut t ToolPoint) draw( d ui.DrawDevice, c ui.CanvasLayout, x f64, y f64 ) {
    if t.hover is model.Point {
        t.hover.draw( d, c, .cursor )
    } else {
        model.Point{ x: x, y: y }.draw( d, c, .cursor )
    }
}

fn (mut t ToolPoint) move( x f64, y f64 ) {
    if t.dragging.on {
        if mut t.hover is model.Point {
            t.hover.move( x - t.dragging.dx, y - t.dragging.dy )
            t.dragging.dirty = true
        }
    }
    else {
        t.hover = t.model.test( x, y, fn( g model.Geom ) bool {
            return g is model.Point
        } )
        t.model.set_highlighted( t.hover )
    }
}

fn (mut t ToolPoint) down( x f64, y f64 ) {
    if mut t.hover is model.Point {
        t.model.set_selected( t.hover )
        hx, hy := t.hover.handle()
        t.dragging = Dragging{
            on: true
            dx: x - hx
            dy: y - hy
            dirty: false
        }
    }
}

fn (mut t ToolPoint) up( x f64, y f64 ) {
    if t.dragging.on {
        t.dragging.on = false
        if t.dragging.dirty {
            t.model.autosave()
        }
    } else {
        mut point := model.Point{ x: x, y: y }
        t.model.add( mut point, .points )
        t.model.set_highlighted( point )
        t.model.clear_selected()
        t.hover = point
    }
}

fn (mut t ToolPoint) menu( x f64, y f64 ) {
    t.model.clear_selected()
    if mut t.hover is model.Point {
        t.model.remove( mut t.hover )
        t.hover = &model.None{}
        t.move( x, y )
    }
}
