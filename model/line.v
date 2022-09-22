// line.v
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

module model

import ui
import gx
//import json
import math

//

/*pub struct InfLine {*/
/*pub:*/
/*    m f64*/
/*    c f64*/
/*}*/

//

const thickness = 5


pub struct Line {
//    InfLine
    pub mut:
    p1 &Point
    p2 &Point
}

pub fn new_line( p1 &Point, p2 &Point ) Line {
    //m := ( p2.y - p1.y ) / ( p2.x - p1.x )
    return Line {
        /*m: m*/
        /*c: p1.y - m * p1.x*/
        p1: p1
        p2: p2
    }
}

fn (l Line) get_m_and_c() (f64, f64) {
    m := ( l.p2.y - l.p1.y ) / ( l.p2.x - l.p1.x )
    c := l.p1.y - m * l.p1.x
    return m, c
}

pub fn (l Line) test( x f64, y f64 ) f64 {
    m, c := l.get_m_and_c()

    a := m
    b := -1
    d := math.abs( a * x + b * y + c ) / math.sqrt( a * a + b * b )
    return if d < thickness { d } else { -1 }
}

pub fn (l Line) draw( d ui.DrawDevice, c ui.CanvasLayout, how UIState ) {
    y := ( l.p2.y - l.p1.y ) / l.length()
    mut a := math.acos( y )
    if l.p2.x < l.p1.x { a = math.tau - a }
    a -= math.pi_2
    mut sa, mut ca := math.sincos( a )
    ht := thickness / 2 + if how == .cursor { 2 } else { 0 }
    sa *= ht
    ca *= ht
    pts := [ f32(l.p1.x - sa), f32(l.p1.y - ca),
             f32(l.p2.x - sa), f32(l.p2.y - ca),
             f32(l.p2.x + sa), f32(l.p2.y + ca),
             f32(l.p1.x + sa), f32(l.p1.y + ca) ]

    if how != .cursor {
        m, cc := l.get_m_and_c()
        c.draw_device_line( d, 0, cc, c.width, c.width * m + cc, gx.light_gray )
    }
    match how {
        .normal {
            if l.p1 != l.p2 {
                c.draw_device_convex_poly(d, pts, gx.gray )
            }
        }
        .selected {
            if l.p1 != l.p2 {
                c.draw_device_convex_poly(d, pts, gx.black )
            }
            /*c.draw_device_line( d, l.p1.x, l.p1.y, l.p2.x, l.p2.y, gx.black )*/
        }
        .highlighted {
            if l.p1 != l.p2 {
                c.draw_device_convex_poly(d, pts, gx.light_gray )
            }
            //c.draw_device_line( d, l.p1.x, l.p1.y, l.p2.x, l.p2.y, gx.light_gray )
            /*m, cc := l.get_m_and_c()*/
            /*c.draw_device_line( d, 0, cc, c.width, c.width * m + cc, gx.light_gray )*/
        }
        .cursor {
            c.draw_device_line( d, l.p1.x + sa, l.p1.y + ca, l.p2.x + sa, l.p2.y + ca, gx.gray )
            c.draw_device_line( d, l.p1.x - sa, l.p1.y - ca, l.p2.x - sa, l.p2.y - ca, gx.gray )
            c.draw_device_arc_line( d, l.p1.x, l.p1.y, ht, f32( a - math.pi ), f32( a ), 8, gx.gray )
            c.draw_device_arc_line( d, l.p2.x, l.p2.y, ht, f32( a ), f32( a + math.pi ), 8, gx.gray )
        }
    }
}

pub fn (mut l Line) add() {
    l.p1.register_dep( l )
    l.p2.register_dep( l )
}

pub fn (mut l Line) remove() []Geom {
    l.p1.unregister_dep( l )
    l.p2.unregister_dep( l )
    return []
}

pub fn (mut l Line) move( x f64, y f64 ) {
}

pub fn (l Line) length() f64 {
    w := l.p2.x - l.p1.x
    h := l.p2.y - l.p1.y
    return math.sqrt( w * w + h * h )
}

/*pub fn (mut l Line) serialize() string {*/
/*    return json.encode( [ Geom( l.p1 ).hash(), Geom( l.p2 ).hash() ] )*/
/*}*/

/*pub fn (mut l Line) unserialize( r map[string]Geom, g string ) bool {*/
/*    return false*/
/*}*/
