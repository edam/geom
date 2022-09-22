// point.v
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

module model

import math
import ui
import gx
//import json

//

const radius = 16

[heap]
pub struct Point {
    pub mut:
    x f64
    y f64
    mut:
    deps []Geom = []Geom{}
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

pub fn (p Point) draw( d ui.DrawDevice, c ui.CanvasLayout, how UIState ) {
    match how {
        .normal {
            c.draw_device_circle_filled( d, p.x, p.y, radius, gx.gray )
        }
        .selected {
            c.draw_device_circle_filled( d, p.x, p.y, radius, gx.black )
        }
        .highlighted {
            c.draw_device_circle_filled( d, p.x, p.y, radius, gx.light_gray )
        }
        .cursor {
            c.draw_device_circle_empty( d, p.x, p.y, radius + 2, gx.black )
        }
    }
}

pub fn (p Point) test( x f64, y f64 ) f64 {
    d := p.distance_to( Point{
        x: x
        y: y
    } )
    return if d < radius { d } else { -1 }
}

pub fn (mut p Point) move( x f64, y f64 ) {
    p.x = x
    p.y = y
}

pub fn (mut p Point) add() {}

pub fn (mut p Point) remove() []Geom {
    return p.deps
}

pub fn (mut p Point) register_dep( g Geom ) {
    p.deps << g
}

pub fn (mut p Point) unregister_dep( g Geom ) {
    for i, dg in p.deps {
        if dg == g {
            p.deps.delete( i )
            break
        }
    }
    println( p.deps )
}

/*pub fn (mut p Point) serialize() string {*/
/*    return json.encode( [ p.x, p.y ] )*/
/*}*/

/*pub fn (mut p Point) unserialize( r map[string]Geom, g string ) bool {*/
/*    return false*/
/*}*/
