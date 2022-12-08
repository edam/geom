// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module win

import ui
//import gx
import model

struct ToolLine {
    pub:
    name string
    title string
    mut:
    model &model.Model
    anchor model.Geom = model.None{}
    hover model.Geom = model.None{}
    dragging Dragging
}

fn new_line_tool( mut model &model.Model ) &ToolLine {
    return &ToolLine{
        name: "line"
        title: "Line"
        model: model
    }
}

fn (mut t ToolLine) reset() {
    t.anchor = &model.None{} // TODO: make t.anchor ?model.Point
    t.hover = &model.None{}
}

fn (mut t ToolLine) draw( d ui.DrawDevice, c ui.CanvasLayout, x f64, y f64 ) {
    mut cursor := if t.hover is model.None {
        model.Geom( model.Point{ x: x, y: y } )
    } else {
        t.hover
    }
    cursor.draw( d, c, .cursor )

    if mut t.anchor is model.Point {
        if mut cursor is model.Point {
            mut line := model.Line {
                p1: t.anchor
                p2: cursor
            }
            line.draw( d, c, .normal )
        }
    }
}

fn (mut t ToolLine) move( x f64, y f64 ) {
    if t.dragging.on {
        if mut t.hover is model.Line {
            t.hover.move( x - t.dragging.dx, y - t.dragging.dy )
            t.dragging.dirty = true
        }
    }
    else {
        t.hover = if t.anchor is model.None {
            // TODO: this code will be loads nice when we have optionals!
            line := t.model.test( x, y, fn( g model.Geom ) bool {
                return g is model.Point
            } )
            if line !is model.None { line } else {
                t.model.test( x, y, fn( g model.Geom ) bool {
                    return g is model.Line
                } )
            }
        } else {
            t.model.test( x, y, fn( g model.Geom ) bool {
                return g is model.Point
            } )
        }
        t.model.set_highlighted( t.hover )
        if mut t.hover is model.Line {
            t.model.add_highlighted( t.hover.p1 )
            t.model.add_highlighted( t.hover.p2 )
        }
    }
}

fn (mut t ToolLine) down( x f64, y f64 ) {
    if mut t.hover is model.Line {
        t.model.set_selected( t.hover )
        t.dragging = Dragging{
            on: true
            dx: x - t.hover.p1.x
            dy: y - t.hover.p1.y
            dirty: false
        }
    }
}

fn (mut t ToolLine) up( x f64, y f64 ) {
    if t.dragging.on {
        t.dragging.on = false
        if t.dragging.dirty {
            t.model.autosave()
        }
    } else if mut t.hover is model.Point {
        if mut t.anchor is model.Point {
            if t.anchor != t.hover {
                mut line := model.Line{
                    p1: t.anchor
                    p2: t.hover
                }

                // is there an existing line for these points?
                existing := t.anchor.get_lines( t.model ).filter(
                    ( it.p1 == t.anchor || it.p1 == t.hover ) &&
                        ( it.p2 == t.anchor || it.p2 == t.hover ) )
                if existing.len == 0 {
                    t.model.add( mut line, .lines )
                    t.model.set_highlighted( line )
                }
            }
            t.anchor = &model.None{}
            t.model.clear_selected()
        } else {
            t.anchor = t.hover
            t.model.set_selected( t.hover )
        }
    }
}

fn (mut t ToolLine) menu( x f64, y f64 ) {
    t.model.clear_selected()
    if t.anchor is model.Point {
        t.anchor = &model.None{}
    } else if mut t.hover is model.Line {
        t.model.remove( mut t.hover )
        t.hover = &model.None{}
        t.move( x, y )
    }
}
