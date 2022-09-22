// tool_point.v
//
// Copyright (C) 2022 Tim Marston <tim@ed.am>
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

struct ToolPoint {
    pub:
    name string
    title string
    mut:
    model &model.Model
    dragging struct {
        mut:
        on bool
        dx f64
        dy f64
    }
}

fn new_point_tool( mut model &model.Model ) &ToolPoint {
    return &ToolPoint{
        name: "point"
        title: "Point"
        model: model
    }
}

fn (mut t ToolPoint) reset() {}

fn (mut t ToolPoint) draw( d ui.DrawDevice, c ui.CanvasLayout, x f64, y f64 ) {
    if t.model.highlighted is model.Point {
        t.model.highlighted.draw( d, c, .cursor )
    } else {
        model.Point{ x: x, y: y }.draw( d, c, .cursor )
    }
}

fn (mut t ToolPoint) move( x f64, y f64 ) {
    if t.dragging.on {
        if mut t.model.highlighted is model.Point {
            t.model.highlighted.move( x - t.dragging.dx, y - t.dragging.dy )
        }
    }
    else {
        t.model.highlight(
            t.model.test( x, y, fn( g model.Geom ) bool {
                return g is model.Point
            } )
        )
    }
}

fn (mut t ToolPoint) down( x f64, y f64 ) {
    if mut t.model.highlighted is model.Point {
        t.model.set_selected( t.model.highlighted )
        t.dragging.on = true
        t.dragging.dx = x - t.model.highlighted.x
        t.dragging.dy = y - t.model.highlighted.y
    }
}

fn (mut t ToolPoint) up( x f64, y f64 ) {
    if t.dragging.on {
        t.dragging.on = false
    } else {
        mut point := model.Point{ x: x, y: y }
        t.model.add( mut point, .points )
        t.model.highlight( point )
        t.model.clear_selected()
    }
}

fn (mut t ToolPoint) menu( x f64, y f64 ) {
    t.model.clear_selected()
    if mut t.model.highlighted is model.Point {
        t.model.remove( mut t.model.highlighted )
    }
}
