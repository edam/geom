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
    dragging struct {
        mut:
        on bool
        dx f64
        dy f64
    }
}

fn new_line_tool( mut model &model.Model ) &ToolLine {
    return &ToolLine{
        name: "line"
        title: "Line"
        model: model
    }
}

fn (mut t ToolLine) reset() {
    t.anchor = model.None{} // TODO: make t.anchor ?model.Point
}

fn (mut t ToolLine) draw( d ui.DrawDevice, c ui.CanvasLayout, x f64, y f64 ) {
    mut cursor := if t.model.highlighted is model.None {
        model.Geom( model.Point{ x: x, y: y } )
    } else {
        t.model.highlighted
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
        if mut t.model.highlighted is model.Line {
            t.model.highlighted.move( x - t.dragging.dx, y - t.dragging.dy )
        }
    }
    else {
        t.model.highlight(
            if t.anchor is model.None {
                t.model.test( x, y, fn( g model.Geom ) bool {
                    return g is model.Point || g is model.Line
                } )
            } else {
                t.model.test( x, y, fn( g model.Geom ) bool {
                    return g is model.Point
                } )
            }
        )
    }
}

fn (mut t ToolLine) down( x f64, y f64 ) {
    if mut t.model.highlighted is model.Line {
        t.model.set_selected( t.model.highlighted )
        t.dragging.on = true
        t.dragging.dx = x - t.model.highlighted.p1.x
        t.dragging.dy = y - t.model.highlighted.p1.y
    }
}

fn (mut t ToolLine) up( x f64, y f64 ) {
    if t.dragging.on {
        t.dragging.on = false
    } else if mut t.model.highlighted is model.Point {
        if mut t.anchor is model.Point {
            if t.anchor != t.model.highlighted {
                mut line := model.Line{ t.anchor, t.model.highlighted }
                t.model.add( mut line, .lines )
                t.model.highlight( line )
            }
            t.anchor = model.None{}
            t.model.clear_selected()
        } else {
            t.anchor = t.model.highlighted
            t.model.set_selected( t.model.highlighted )
        }
    }
}

fn (mut t ToolLine) menu( x f64, y f64 ) {
    t.model.clear_selected()
    if t.anchor is model.Point {
        t.anchor = model.None{}
    } else if mut t.model.highlighted is model.Line {
        t.model.remove( mut t.model.highlighted )
    }
}
