// Copyright (c) 2022 Tim Marston <tim@ed.am>.  All rights reserved.
// Use of this file is permitted under the terms of the GNU General Public
// Licence, version 3 or later, which can be found in the LICENCE file.

module model

import math
import ui
import gx
import regex
import strings

//

const point_radius = 6

pub struct Point {
    pub mut:
    x f64
    y f64
    mut:
    deps []Id = []Id{}
    id Id
}

// TODO: make references!
fn (p Point) ==( o Point ) bool {
    return p.id == o.id
}

pub fn (p Point) distance_to( o Point ) f64 {
    dx := math.abs( o.x - p.x )
    dy := math.abs( o.y - p.y )
    return math.sqrt( dx * dx + dy * dy )
}

/*pub fn (p Point) offset( dx f64, dy f64 ) Point {*/
/*    return Point{ p.x + dx, p.y + dy }*/
/*}*/

// interface Drawable

pub fn (p Point) kind() string {
    return 'point'
}

pub fn (p Point) test( x f64, y f64 ) f64 {
    d := p.distance_to( Point{
        x: x
        y: y
    } )
    return if d < point_radius { d } else { -1 }
}

pub fn (p Point) draw( d ui.DrawDevice, c ui.CanvasLayout, how UIState ) {
    match how {
        .normal {
            c.draw_device_circle_filled( d, p.x, p.y, point_radius, gx.gray )
        }
        .highlighted {
            c.draw_device_circle_filled( d, p.x, p.y, point_radius, gx.light_gray )
        }
        .selected {
            c.draw_device_circle_filled( d, p.x, p.y, point_radius, gx.black )
        }
        .cursor {
            c.draw_device_circle_empty( d, p.x, p.y, point_radius + cursor_expand, gx.black )
        }
    }
}

pub fn (p Point) handle() ( f64, f64 ) {
    return p.x, p.y
}

pub fn (mut p Point) move( x f64, y f64 ) {
    p.x = x
    p.y = y
}

pub fn (mut p Point) add( id Id ) {
    p.id = id
}

pub fn (mut p Point) remove() []Id {
    return p.deps
}

pub fn (mut p Point) register_dep( g Geom ) {
    p.deps << g.id
}

pub fn (mut p Point) unregister_dep( g Geom ) {
    for i, id in p.deps {
        if id == g.id {
            p.deps.delete( i )
            break
        }
    }
}

pub fn (p Point) get_lines( m Model ) []&Line {
    mut lines := []&Line{}
    for _, id in p.deps {
        mut g := m.geometry( id )
        if mut g is Line {
            lines << g
        }
    }
    return lines
}

fn (p Point) serialise( mut out strings.Builder ) {
    out.writeln( "${p.x},${p.y}" )
}

fn (mut p Point) unserialise( mut loader Loader, mut model Model ) !
{
    line := loader.next_line()!
    mut re := regex.regex_opt( "^(-?[0-9]+(?:\\.[0-9]+)?),(-?[0-9]+(?:\\.[0-9]+)?)$" ) or {
        panic( err )
    }
    if !re.matches_string( line ) {
       return error( "bad point data, line ${loader.line_no}" )
    }
    p.x = re.get_group_by_id( line, 0 ).f64()
    p.y = re.get_group_by_id( line, 1 ).f64()
}
